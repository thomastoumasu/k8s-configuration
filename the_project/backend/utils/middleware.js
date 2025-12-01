const logger = require('./logger');
const morgan = require('morgan');

morgan.token('postedData', req => {
  // log data sent in POST requests. (req, res)
  if (req.method === 'POST') {
    return JSON.stringify(req.body);
  } else {
    return null;
  }
});

const requestLogger = morgan(
  ':method :url :status :res[content-length] - :response-time ms :postedData',
  { skip: () => process.env.NODE_ENV === 'test' }
);

const unknownEndpoint = (req, res) => {
  res.status(404).send({ error: 'unknown endpoint' });
};

const errorHandler = (error, request, response, next) => {
  logger.error(error.message);
  if (error.name === 'CastError') {
    return response.status(400).send({ error: 'malformatted id' }); // bad request
  } else if (error.name === 'ValidationError') {
    return response.status(400).json({ error: error.message }); // bad request
  }
  next(error);
};

module.exports = { requestLogger, unknownEndpoint, errorHandler };
