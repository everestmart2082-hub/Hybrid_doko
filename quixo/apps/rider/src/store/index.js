import { configureStore } from '@reduxjs/toolkit';
import riderReducer from './riderSlice';
import orderReducer from './orderSlice';
export default configureStore({ reducer: { rider: riderReducer, order: orderReducer } });