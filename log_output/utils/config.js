import 'dotenv/config';

const PINGPONG_URL = process.env.PINGPONG_URL || 'http://localhost:3002/counter';
const PORT = process.env.PORT || 3000;
const MESSAGE = process.env.MESSAGE || 'no message';

export { PINGPONG_URL, PORT, MESSAGE };
