import { useEffect, useRef } from 'react';
import { io } from 'socket.io-client';
export const useSocket = (event, handler) => {
  const socket = useRef(null);
  useEffect(() => {
    socket.current = io(import.meta.env.VITE_API_URL?.replace('/api','') || 'http://localhost:5000');
    socket.current.on(event, handler);
    return () => socket.current.disconnect();
  }, [event]);
  return socket;
};