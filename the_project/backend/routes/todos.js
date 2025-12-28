import { info } from '../utils/logger.js';
import { Todo } from '../models/Todo.js';
import express from 'express';
const router = express.Router();
import NATS from 'nats';
// const nc = NATS.connect({
//   url: process.env.NATS_URL || 'nats://nats:4222',
// });

router.get('/', async (req, res) => {
  const todos = await Todo.find({});
  res.send(todos);
  console.log('todos: ', todos);
});

router.post('/', async (req, res) => {
  const newTodo = req.body;
  info(`--server: received post request for: ${JSON.stringify(newTodo)}`);
  if (newTodo.text.length > 140) {
    info('--server: Todo too long. Cannot create Todo.');
    return res.status(400).json({
      error: 'Todo too long',
    });
  } else {
    const todo = await Todo.create({
      text: newTodo.text,
    });
    res.send(todo);
    info(`--server: so created following Todo: ${JSON.stringify(todo)}`);
    // nc.publish('new_todos', JSON.stringify(newTodo));
  }
});

router.put('/:id', async (req, res) => {
  info(`--server: received put request for this todo: ${JSON.stringify(req.body)} at id: ${req.params.id}`);
  const todoToUpdate = await Todo.findById(req.params.id);
  if (!todoToUpdate) {
    return res.status(410).end(); // gone
  }
  todoToUpdate.done = req.body.done;
  const updatedTodo = await todoToUpdate.save(); // findByIdAndUpdate should be better than findById and save
  res.json(updatedTodo);
  // const todoToUpdate = todos.find(todo => todo.id === req.params.id);
  // todoToUpdate.done = req.body.done;
  // res.json(todoToUpdate);
});

export default router;
