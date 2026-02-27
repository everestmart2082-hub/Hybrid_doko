const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');

let io;

/**
 * Initialize Socket.io with JWT authentication middleware,
 * rider location tracking, and order status broadcasting.
 */
exports.initSocket = (server) => {
  io = new Server(server, {
    cors: {
      origin: ['http://localhost:3000', 'http://localhost:3001', 'http://localhost:3002', 'http://localhost:3003'],
      credentials: true
    }
  });

  // ── JWT Auth Middleware ──
  io.use((socket, next) => {
    try {
      const token = socket.handshake.auth?.token;
      if (!token) return next(new Error('Authentication required'));
      // Try regular JWT first, then admin JWT
      let decoded;
      try {
        decoded = jwt.verify(token, process.env.JWT_SECRET);
      } catch {
        decoded = jwt.verify(token, process.env.JWT_ADMIN_SECRET);
      }
      socket.userId = decoded.id;
      socket.userRole = decoded.role;
      next();
    } catch (err) {
      next(new Error('Invalid or expired token'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`✅ Socket connected: ${socket.userId} (${socket.userRole})`);

    // Auto-join user-specific room
    socket.join(`user:${socket.userId}`);

    // Join order-specific room for tracking
    socket.on('join:order', (orderId) => {
      socket.join(`order:${orderId}`);
      console.log(`📦 User ${socket.userId} watching order ${orderId}`);
    });

    socket.on('leave:order', (orderId) => {
      socket.leave(`order:${orderId}`);
    });

    // Rider-specific events
    if (socket.userRole === 'rider') {
      // Rider location — only broadcast to the specific order rooms
      // the rider is currently delivering for, not to everyone
      socket.on('rider:location', ({ orderId, location }) => {
        if (orderId) {
          io.to(`order:${orderId}`).emit('riderLocation', {
            riderId: socket.userId,
            location,
            timestamp: new Date()
          });
        }
      });

      socket.on('rider:available', (isAvailable) => {
        // Only broadcast to admin/vendor rooms, not all clients
        io.to('role:admin').to('role:vendor').emit('riderAvailability', {
          riderId: socket.userId,
          isAvailable
        });
      });
    }

    // Auto-join role-based rooms for admin/vendor
    if (['admin', 'vendor'].includes(socket.userRole)) {
      socket.join(`role:${socket.userRole}`);
    }

    socket.on('disconnect', () => {
      console.log(`❌ Socket disconnected: ${socket.userId}`);
    });
  });

  return io;
};

exports.getIO = () => {
  if (!io) throw new Error('Socket.io not initialized');
  return io;
};

/**
 * Emit an event to a specific user by their userId.
 */
exports.emitToUser = (userId, event, data) => {
  if (io) io.to(`user:${userId}`).emit(event, data);
};

/**
 * Emit an order status update to everyone watching that order.
 */
exports.emitOrderUpdate = (orderId, data) => {
  if (io) io.to(`order:${orderId}`).emit('orderStatusChanged', data);
};