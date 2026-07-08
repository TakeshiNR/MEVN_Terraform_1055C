const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const connectDB = require('./config/db');
const taskRoutes = require('./routes/task.routes');
const errorHandler = require('./middlewares/error.middleware');

connectDB();

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: 'Task API is running',
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
  });
});

app.use('/api/tasks', taskRoutes);

app.use(errorHandler);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
