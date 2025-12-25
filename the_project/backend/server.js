import express from 'express';
import todosRouter from './routes/todos.js';
import middleware from './utils/middleware.js';
import cors from 'cors';
import mongoose from 'mongoose';
import { info, error } from './utils/logger.js';

const server = express();
server.use(express.json());
server.use(cors());
server.use(middleware.requestLogger);

server.get('/ping', (_req, res) => {
  res.send('pong');
});

server.get('/', (_req, res) => {
  res.send('<h2>Hello k8s</h2>');
});

server.get('/health', async (req, res) => {
  // health check ensuring that the app deployed is in a functional state.
  info('Received a request to health, checking connection to the database:');
  if (mongoose.connection.readyState == 1) {
    info('--backend still connected to MongoDB');
    return res.sendStatus(200);
  } else {
    mongoose
      .connect(url)
      .then(() => {
        info('--backend was not connected to MongoDB but could reestablish a connexion');
        return res.sendStatus(200);
      })
      .catch(err => {
        error('--backend unable to connect to MongoDB. Error:\n', err.message);
        return res.sendStatus(500);
      });
  }
});

server.use('/api/todos', todosRouter);
export default server;
