import { useState } from 'react';

const TodoForm = ({ createTodo }) => {
  const [newTodo, setNewTodo] = useState('');

  const addTodo = event => {
    event.preventDefault();
    const todoObject = {
      text: newTodo,
    };
    createTodo(todoObject);
    setNewTodo('');
  };

  return (
    <div>
      <form onSubmit={addTodo}>
        <input value={newTodo} onChange={({ target }) => setNewTodo(target.value)} />
        <button type="submit">Create todo</button>
      </form>
    </div>
  );
};

export default TodoForm;
