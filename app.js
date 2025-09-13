const express = require('express');
const path = require('path');
const app = express();

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'logoswayatt.png'));
});

module.exports = app; // Export the app for testing and server.js