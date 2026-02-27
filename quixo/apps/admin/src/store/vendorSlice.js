import { createSlice } from '@reduxjs/toolkit';

const initialState = {
  data: [],
  loading: false,
  error: null,
};

const vendorSlice = createSlice({
  name: 'vendor',
  initialState,
  reducers: {
    setLoading: (state, action) => { state.loading = action.payload; },
    setError:   (state, action) => { state.error   = action.payload; },
    setData:    (state, action) => { state.data    = action.payload; },
    reset:      () => initialState,
  },
});

export const { setLoading, setError, setData, reset } = vendorSlice.actions;
export default vendorSlice.reducer;
