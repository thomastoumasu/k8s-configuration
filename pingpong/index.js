import express from 'express';

const PORT = process.env.PORT || 3000;
let counter = 0;

const app = express();
app.use(express.json());

app.get('/pingpong', (_req, res) => {
  res.send(`pong ${counter}`);
  counter += 1;
});

app.listen(PORT, () => {
  console.log(`server started in port ${PORT}`);
});
