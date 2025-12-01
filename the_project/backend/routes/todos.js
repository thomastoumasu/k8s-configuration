import logger from '../utils/logger.js';
import express from 'express';
const router = express.Router();

let todos = [
  {
    id: '1',
    text: 'relax',
  },
  {
    id: '2',
    text: 'drink coffee',
  },
  {
    id: '3',
    text: 'drink more coffee',
  },
];

router.get('/', (req, res) => {
  res.json(todos);
});

router.post('/', (req, res) => {
  const newTodo = req.body;
  logger.info(`--server: received post request for: ${JSON.stringify(newTodo)}`);
  if (newTodo.text.length > 140) {
    logger.info('--server: Todo too long. Cannot create Todo.');
    return res.status(400).json({
      error: 'Todo too long',
    });
  } else {
    const newId = todos.length > 0 ? Math.floor(Math.random() * Number.MAX_SAFE_INTEGER) : 0;
    newTodo.id = String(newId);
    logger.info(`--server: so creating following Todo: ${JSON.stringify(newTodo)}`);
    todos = todos.concat(newTodo);
    res.json(newTodo);
  }
});

export default router;
