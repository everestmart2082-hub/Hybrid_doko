import { configureStore } from '@reduxjs/toolkit';
import vendorReducer  from './vendorSlice';
import productReducer from './productSlice';
import orderReducer   from './orderSlice';
export default configureStore({ reducer: { vendor: vendorReducer, product: productReducer, order: orderReducer } });