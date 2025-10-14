const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files from public directory
app.use(express.static(path.join(__dirname, 'public')));
app.use('/assets', express.static(path.join(__dirname, 'assets')));

// Serve the main page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'yeehaw', message: 'Welcome to Code Country!' });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🤠 Code Country server is running on port ${PORT}`);
    console.log(`🐎 Visit http://localhost:${PORT} to enter Code Country!`);
});