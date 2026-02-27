import { configureStore } from '@reduxjs/toolkit';
import adminReducer    from './adminSlice';
import vendorReducer   from './vendorSlice';
import riderReducer    from './riderSlice';
import clientReducer   from './clientSlice';
import employeeReducer from './employeeSlice';
export default configureStore({
  reducer: { admin: adminReducer, vendor: vendorReducer, rider: riderReducer, client: clientReducer, employee: employeeReducer }
});