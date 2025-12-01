const TodosList = ({ todos }) => {
  return (
    <>
      {/* <h2>Todos</h2> */}
      <ul>
        {todos.map(todo => (
          <li className="todo" key={todo.id}>
            {todo.text}
          </li>
        ))}
      </ul>
    </>
  );
};

export default TodosList;
