import logger from './utils/logger.js';
import { PORT } from './utils/config.js';
import server from './server.js';

server.listen(PORT, () => {
  logger.info(`server started in port ${PORT}`);
});
