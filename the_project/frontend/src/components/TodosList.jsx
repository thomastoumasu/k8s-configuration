import { MdOutlineDone } from 'react-icons/md';

const TodosList = ({ todos, complete }) => {
  return (
    <>
      <ul>
        {todos
          .filter(todo => !todo.done)
          .map(todo => (
            <li className="todo" key={todo.id}>
              {todo.text}{' '}
              <button onClick={complete(todo.id)}>
                <MdOutlineDone color="#15d465" />
              </button>
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
