import Koa from 'koa';
import axios from 'axios';
import path from 'path';
import fs from 'fs';
import { PINGPONG_URL, PORT, MESSAGE } from './utils/config.js';
import Router from '@koa/router';
const router = new Router();

let isReady = false;

const app = new Koa();
const randomString = Math.random().toString(36);
// const directory = './';
const directory = '/config';
const filePath = path.join(directory, 'information.txt');
const getFile = async () =>
  new Promise(res => {
    fs.readFile(filePath, (err, buffer) => {
      if (err) {
        console.log('FAILED TO READ FILE', '----------------', err);
        return res(false);
      }
      return res(buffer);
    });
  });

router.get('/', async ctx => {
  if (ctx.path.includes('favicon.ico')) return;
  let counter = 0;
  try {
    const response = await axios.get(PINGPONG_URL);
    console.log(`got counter: ${response.data} from ${PINGPONG_URL}`);
    counter = response.data;
  } catch {
    console.log(`error from ${PINGPONG_URL}. Counter defaulted to zero.`);
  }
  const configContent = await getFile();

  ctx.body = `file content: ${configContent}\nenv variable: MESSAGE=${MESSAGE}\n${new Date().toISOString()}: ${randomString} \nPing / Pongs: ${counter}`;
  ctx.set('Content-type', 'text/plain');
  ctx.status = 200;
});

router.get('/health', ctx => {
  ctx.status = isReady ? 200 : 500;
  console.log(`Received a request to health and responding with status ${ctx.status}`);
});

app.use(router.routes());

app.listen(PORT, () => {
  console.log(`Log-output app: server started in port ${PORT}`);
  isReady = true;
});
