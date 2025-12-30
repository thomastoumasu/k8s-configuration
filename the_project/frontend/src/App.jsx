import './App.css';
import { useState, useEffect } from 'react';
import HourlyImage from './components/HourlyImage';
import TodoForm from './components/TodoForm';
import TodosList from './components/TodosList';
import todoService from './services/todos.js';

function App() {
  const [todos, setTodos] = useState([]);

  useEffect(() => {
    todoService.getAll().then(todos => {
      setTodos(todos);
      // console.log('fetched: ', todos);
    });
  }, []);

  const addTodo = todoObject => {
    todoService.create(todoObject).then(returnedTodo => {
      setTodos(todos.concat(returnedTodo));
    });
  };

  const completeTodo = id => () => {
    const todo = todos.find(todo => todo.id === id);
    const todoToUpdate = { ...todo, done: true };
    todoService
      .update(id, todoToUpdate)
      .then(updatedTodo => {
        setTodos(todos.map(todo => (todo.id !== id ? todo : updatedTodo)));
      })
      .catch(error => {
        console.log(error);
      });
  };

  return (
    <>
      <h1>The project App</h1>
      <HourlyImage />
      <TodoForm createTodo={addTodo} />
      <TodosList todos={todos} complete={completeTodo} />
      <p className="footer">DevOps with Kubernetes 2025</p>
    </>
  );
}

export default App;
