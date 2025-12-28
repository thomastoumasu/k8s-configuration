import axios from 'axios';
import NATS from 'nats';
import os from 'os';

const hostname = os.hostname();

const nc = NATS.connect({
  url: process.env.NATS_URL || 'nats://nats:4222',
});

const webhook = process.env.DISCORD_WEBHOOK || 'https://study.cs.helsinki.fi/discord/webhooks/';

let preoccupied = false;

const setReadyToBroadcast = () => {
  const data_subscription = nc.subscribe('todos', { queue: 'broadcaster.workers' }, msg => {
    console.log(`Broadcaster ${hostname} received msg: ${msg}`);
    preoccupied = true;
    nc.unsubscribe(data_subscription);
    broadcastTodo(JSON.parse(msg));
  });
  preoccupied = false;
};

const broadcastTodo = async ({ text, done }) => {
  // https://discord.com/developers/docs/resources/message#embed-object
  console.log('Processing...');
  const content = done
    ? 'A Todo was completed on http://www.thomastoumasu.dpdns.org'
    : 'A new Todo was created on http://www.thomastoumasu.dpdns.org';
  const payload = {
    content,
    username: 'thomastoumasu',
    avatar_url: 'https://gravatar.com/avatar/42dd784b61ac3992e45bdf1d1454ec05?s=200&d=robohash&r=r',
    embeds: [
      {
        description: text,
        color: hostname.charCodeAt(28) * 500,
        footer: {
          text: `by broadcaster named ${hostname}`,
        },
      },
    ],
  };
  axios.post(webhook, payload);
  console.log(`Broadcaster ${hostname} sent the payload`);
  setReadyToBroadcast();
};

setReadyToBroadcast();
console.log(`Broadcaster ${hostname} listening`);
