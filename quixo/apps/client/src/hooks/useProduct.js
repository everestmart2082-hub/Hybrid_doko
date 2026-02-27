import { useSelector } from 'react-redux';
export const useProduct = () => useSelector((s) => s.product);