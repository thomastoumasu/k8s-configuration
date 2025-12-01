import './App.css';
import { useState, useEffect } from 'react';
import HourlyImage from './components/HourlyImage';
import TodosList from './components/TodosList';
import TodoForm from './components/TodoForm';
import todoService from './services/todos.js';

function App() {
  const [todos, setTodos] = useState([]);

  useEffect(() => {
    todoService.getAll().then(todos => {
      setTodos(todos);
    });
  }, []);

  const addTodo = todoObject => {
    todoService.create(todoObject).then(returnedTodo => {
      setTodos(todos.concat(returnedTodo));
    });
  };

  return (
    <>
      <h1>The project App</h1>
      <HourlyImage />
      <TodoForm createTodo={addTodo} />
      <TodosList todos={todos} />
      <p className="footer">DevOps with Kubernetes 2025</p>
    </>
  );
}

export default App;
