import 'dotenv/config';

const PORT = process.env.PORT || 3002;
const DATABASE_URL =
  process.env.DATABASE_URL || 'postgres://postgres:mysecretpassword@localhost:5432/postgres';

export { PORT, DATABASE_URL };
