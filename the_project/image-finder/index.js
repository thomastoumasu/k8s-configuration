import fs from 'fs';
import path from 'path';
import axios from 'axios';

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

const writeImage = async () => {
  // create directory if image does not yet exist
  await findAFile();
  try {
    const response = await axios.get('https://picsum.photos/1200', { responseType: 'stream' });
    response.data.pipe(fs.createWriteStream(filePath));
    const log = `${new Date().toISOString()}: wrote new hourly image to file`;
    console.log(log);
  } catch (err) {
    console.log('could not fetch hourly image, check network connection. Error: ', err.message);
  }
  setTimeout(writeImage, 5000);
};

console.log('Image finder service started');

// define path to image
const directory = path.join('/', 'shared');
// const directory = '../frontend/public/shared';
const filePath = path.join(directory, 'hourlyImage.jpg');

// write image every 5 s
writeImage();
