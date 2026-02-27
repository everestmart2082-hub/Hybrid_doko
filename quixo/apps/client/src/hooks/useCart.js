import { useSelector } from 'react-redux';
export const useCart = () => useSelector((s) => s.cart);