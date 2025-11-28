import fs from 'fs';
import path from 'path';

const fileAlreadyExists = async () =>
  new Promise(res => {
    fs.stat(filePath, (err, stats) => {
      if (err || !stats) return res(false);
      return res(true);
    });
  });

const findAFile = async () => {
  if (await fileAlreadyExists()) return;
  await new Promise(res => fs.mkdir(directory, err => res()));
};

const writeLogs = (someString, stream) => {
  const log = `${new Date().toISOString()}: ${someString}`;

  console.log(log);
  stream.write(log + '\n');

  setTimeout(writeLogs, 5000, someString, stream);
};

// create random string
const randomString = Math.random().toString(36);

// define path to log file
const directory = path.join('/', 'usr', 'src', 'app', 'files');
// const directory = '../logs/';
const filePath = path.join(directory, 'logs.txt');

// create write stream to the log file
console.log('Write app: started');
await findAFile();
const stream = fs.createWriteStream(filePath, { flags: 'as' });

// write log every 5
writeLogs(randomString, stream);
