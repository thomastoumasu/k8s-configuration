import express from 'express';
import { PORT } from './utils/config.js';
import { Counter } from './postgres/postgres.js';

console.log('Pingpong app: started');

const app = express();
app.use(express.json());

app.get('/', async (_req, res) => {
  const counter = await Counter.findByPk(1);
  counter.value += 1;
  res.send(`pong ${counter.value}`);
  await counter.save();
});

app.get('/counter', async (_req, res) => {
  const counter = await Counter.findByPk(1);
  res.send(counter.value);
});

app.listen(PORT, () => {
  console.log(`server started in port ${PORT}`);
});
