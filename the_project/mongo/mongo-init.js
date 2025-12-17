console.log('mongo-init.js was called: start');
db.createUser({
  user: 'the_username',
  pwd: 'the_password',
  roles: [{ role: 'dbOwner', db: 'the_database' }],
});
db.createCollection('todos');
db.todos.insert({ text: 'relax' });
db.todos.insert({ text: 'drink coffee' });
console.log('mongo-init.js was called: end');
