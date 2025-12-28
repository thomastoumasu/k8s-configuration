import axios from 'axios';
// const baseUrl = 'http://localhost:3000/api/todos';
const baseUrl = import.meta.env.VITE_BACKEND_URL;

const getAll = () => {
  const request = axios.get(baseUrl);
  return request.then(response => response.data);
};

const create = async newObject => {
  const response = await axios.post(baseUrl, newObject);
  return response.data;
};

const update = async (id, newObject) => {
  const response = await axios.put(`${baseUrl}/${id}`, newObject);
  return response.data;
};

export default {
  getAll,
  create,
  update,
};
