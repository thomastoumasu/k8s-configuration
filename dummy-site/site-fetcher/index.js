import fs from 'fs';
import path from 'path';
import axios from 'axios';

const SITE = process.env.SITE || 'http://www.example.com';

// define path to file
const directory = path.join('/', 'shared');
// const directory = '../';
const filePath = path.join(directory, 'index.html');

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

const writeSite = async () => {
  // create directory if file does not yet exist
  await findAFile();
  try {
    const response = await axios.get(SITE, {
      responseType: 'stream',
      headers: {
        'User-Agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15',
      },
    });
    // const response = await axios.get('https://picsum.photos/1200', { responseType: 'stream' });
    response.data.pipe(fs.createWriteStream(filePath));
    const log = `${new Date().toISOString()}: wrote GET response from ${SITE} to file`;
    console.log(log);
  } catch (err) {
    console.log(err);
    console.log(`could not fetch from site ${SITE}, check network connection. Error: ${err}`);
  }
  setTimeout(writeSite, 5000);
};

console.log('Site fetcher service started');

// fetch site every 5 s
writeSite();
