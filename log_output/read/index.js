import Koa from 'koa';
import path from 'path';
import fs from 'fs';

const PORT = process.env.PORT || 3000;
const directory = path.join('/', 'usr', 'src', 'app', 'files');
// const directory = '../logs/';
const filePath = path.join(directory, 'logs.txt');

const app = new Koa();

const getFile = async () =>
  new Promise(res => {
    fs.readFile(filePath, (err, buffer) => {
      if (err) {
        console.log('FAILED TO READ FILE', '----------------', err);
        return res(false);
      }
      return res(buffer);
    });
    // res(false);
  });

app.use(async ctx => {
  if (ctx.path.includes('favicon.ico')) return;
  ctx.body = await getFile();
  ctx.set('Content-type', 'text/plain');
  ctx.status = 200;
});

app.listen(PORT, () => {
  console.log(`Read app: server started in port ${PORT}`);
});
