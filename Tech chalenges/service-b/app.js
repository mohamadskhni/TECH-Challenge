const express = require('express');
const app = express();
const port = process.env.PORT || 3001;

app.get('/health', (req, res) => {
  res.json({ status: 'service-b is healthy' });
});

app.get('/', (req, res) => {
  res.send('Hello from Service B!');
});

app.listen(port, () => {
  console.log(`Service B listening on port ${port}`);
});
