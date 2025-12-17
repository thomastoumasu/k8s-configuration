import { Sequelize, Model, DataTypes } from 'sequelize';
import { DATABASE_URL } from '../utils/config.js';

const sequelize = new Sequelize(DATABASE_URL);

class Counter extends Model {}
Counter.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    value: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
  },
  {
    sequelize,
    underscored: true,
    timestamps: false,
    modelName: 'counter',
  }
);

try {
  await sequelize.authenticate();
  console.log('Connection to postgres has been established successfully.');
  // sequelize.close();
} catch (error) {
  console.error('Unable to connect to the postgres database:', error);
  process.exit();
}

export { Counter };
