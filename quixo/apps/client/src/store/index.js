import { configureStore } from '@reduxjs/toolkit';
import cartReducer    from './cartSlice';
import authReducer    from './authSlice';
import productReducer from './productSlice';
import orderReducer   from './orderSlice';

export default configureStore({
  reducer: { cart: cartReducer, auth: authReducer, product: productReducer, order: orderReducer },
});