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

export { sequelize, Counter };
