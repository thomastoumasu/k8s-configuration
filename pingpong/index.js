import express from 'express';
import { PORT } from './utils/config.js';
import { Counter, sequelize } from './postgres/postgres.js';

console.log('Pingpong app: started');

const app = express();
app.use(express.json());

app.get('/health', async (req, res) => {
  // health check ensuring that the app deployed is in a functional state.
  console.log('Received a request to health, checking connection to the database:');
  try {
    await sequelize.authenticate();
    console.log('Connection to postgres has been established successfully.');
    return res.sendStatus(200);
  } catch (error) {
    console.error('Unable to connect to the postgres database:', error);
    return res.sendStatus(500);
  }
});

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
