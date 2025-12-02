import express from 'express';
const PORT = process.env.PORT || 3002;

console.log('Pingpong app: started');

let counter = 0;

const app = express();
app.use(express.json());

app.get('/pingpong', (_req, res) => {
  counter += 1;
  res.send(`pong ${counter}`);
});

app.get('/counter', (_req, res) => {
  res.send(counter);
});

app.listen(PORT, () => {
  console.log(`server started in port ${PORT}`);
});
