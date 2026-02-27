require('dotenv').config();
const http = require('http');
const app = require('./src/app');
const { initSocket } = require('./src/realtime/socket');
const connectDB = require('./src/config/db');

const PORT = process.env.PORT || 5000;
const server = http.createServer(app);

initSocket(server);
connectDB();

server.listen(PORT, () => console.log(`🚀 Quixo server running on port ${PORT}`));

// ── Graceful Shutdown ──
const shutdown = (signal) => {
    console.log(`\n📴 ${signal} received — shutting down gracefully...`);
    server.close(() => {
        console.log('✅ HTTP server closed');
        const mongoose = require('mongoose');
        mongoose.connection.close(false).then(() => {
            console.log('✅ MongoDB connection closed');
            process.exit(0);
        });
    });

    // Force exit after 10 seconds if graceful shutdown fails
    setTimeout(() => {
        console.error('❌ Forced shutdown after timeout');
        process.exit(1);
    }, 10000);
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// Handle uncaught errors
process.on('unhandledRejection', (reason, promise) => {
    console.error('❌ Unhandled Rejection:', reason);
});

process.on('uncaughtException', (err) => {
    console.error('❌ Uncaught Exception:', err);
    shutdown('uncaughtException');
});
