import axios from 'axios';
import NATS from 'nats';

const nc = NATS.connect({
  url: process.env.NATS_URL || 'nats://nats:4222',
});

const webhook = 'https://study.cs.helsinki.fi/discord/webhooks/1264842173619109949';

let preoccupied = false;

const setReadyToBroadcast = () => {
  const data_subscription = nc.subscribe('new_todos', { queue: 'broadcaster.workers' }, msg => {
    console.log('broadcaster received msg:', msg);
    preoccupied = true;
    nc.unsubscribe(data_subscription);
    broadcastTodo(JSON.parse(msg));
  });
  preoccupied = false;
};

const broadcastTodo = async ({ text }) => {
  console.log('Processing...');
  const payload = {
    content: 'A new Todo was created',
    username: 'thomastoumasu',
    avatar_url: 'https://gravatar.com/avatar/42dd784b61ac3992e45bdf1d1454ec05?s=200&d=robohash&r=r',
    embeds: [
      {
        description: text,
        color: 65280,
      },
    ],
  };
  axios.post(webhook, payload);
  console.log('Data was sent');
  setReadyToBroadcast();
};

setReadyToBroadcast();
console.log('Broadcaster listening');
