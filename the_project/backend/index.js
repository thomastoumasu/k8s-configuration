import { info, error } from './utils/logger.js';
import { PORT, MONGODB_URI } from './utils/config.js';
import server from './server.js';
import mongoose from 'mongoose';

const url = MONGODB_URI;
info('--backend started, initial try to connect to MongoDB through', url);
mongoose
  .connect(url)
  .then(() => {
    info('--backend connected to MongoDB');
  })
  .catch(err => {
    error('--backend could not connect to MongoDB. Error:\n', err.message);
    // process.exit(); // let it crash on purpose so the pod can be restarted and try connecting again
  });

server.listen(PORT, () => {
  info(`backend server started in port ${PORT}`);
});
