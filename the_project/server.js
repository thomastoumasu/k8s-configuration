import express from 'express';
// import todosRouter from "./routes/todos";

const server = express();
server.use(express.json());

server.get('/ping', (_req, res) => {
  res.send('pong');
});

server.get('/', (_req, res) => {
  res.send('<h2>Hello k8s</h2>');
});

// server.use("/api/todos", todosRouter);
export default server;
