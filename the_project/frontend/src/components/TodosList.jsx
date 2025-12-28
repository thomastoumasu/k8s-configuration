const TodosList = ({ todos, completeTodo }) => {
  return (
    <>
      {/* <h2>Todos</h2> */}
      <ul>
        {todos
          .filter(todo => !todo.done)
          .map(todo => (
            <li className="todo" key={todo.id}>
              {todo.text} <button onClick={() => completeTodo(todo.id)}> done </button>
            </li>
          ))}
      </ul>
      <h3>:)</h3>
      <ul>
        {todos
          .filter(todo => todo.done)
          .map(todo => (
            <li className="todo" key={todo.id}>
              {todo.text}
            </li>
          ))}
      </ul>
    </>
  );
};

export default TodosList;
