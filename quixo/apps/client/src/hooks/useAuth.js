import { useSelector, useDispatch } from 'react-redux';
import { setData, reset } from '../store/authSlice';

export const useAuth = () => {
  const dispatch = useDispatch();
  const auth = useSelector((s) => s.auth);
  const logout = () => { localStorage.removeItem('token'); dispatch(reset()); };
  return { ...auth, logout };
};