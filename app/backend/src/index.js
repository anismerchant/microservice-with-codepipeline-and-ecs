const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

let counter = 0;

app.get('/api/counter', (req, res) => {
  res.json({ counter });
});

app.post('/api/counter/increment', (req, res) => {
  counter += 1;
  res.json({ counter });
});

app.get('/health', (req, res) => {
  res.send('OK');
});

const PORT = 8080;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
