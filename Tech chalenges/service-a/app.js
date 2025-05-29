const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/health', (req, res) => {
  res.json({ status: 'service-a is healthy' });
});

app.get('/', (req, res) => {
  res.send('Hello from Service A!');
});

app.listen(port, () => {
  console.log(`Service A listening on port ${port}`);
});
