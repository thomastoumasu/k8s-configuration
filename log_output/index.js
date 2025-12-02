import Koa from 'koa';
import axios from 'axios';
import { PINGPONG_URL, PORT } from './utils/config.js';

const app = new Koa();
const randomString = Math.random().toString(36);

app.use(async ctx => {
  if (ctx.path.includes('favicon.ico')) return;
  let counter = 0;
  try {
    const response = await axios.get(PINGPONG_URL);
    console.log(`got counter: ${response.data} from ${PINGPONG_URL}`);
    counter = response.data;
  } catch {
    console.log(`error from ${PINGPONG_URL}. Counter defaulted to zero.`);
  }

  ctx.body = `${new Date().toISOString()}: ${randomString} \nPing / Pongs: ${counter}`;
  ctx.set('Content-type', 'text/plain');
  ctx.status = 200;
});

app.listen(PORT, () => {
  console.log(`Log-output app: server started in port ${PORT}`);
});
