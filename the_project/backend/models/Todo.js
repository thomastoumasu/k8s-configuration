import mongoose from 'mongoose';

const todoSchema = new mongoose.Schema({
  text: String,
  done: Boolean,
});

blogSchema.set("toJSON", {
  transform: (document, returnedObject) => {
    returnedObject.id = returnedObject._id.toString();
    delete returnedObject._id;
    delete returnedObject.__v;
  },
});

const Todo = mongoose.model('Todo', todoSchema);

export { Todo };
