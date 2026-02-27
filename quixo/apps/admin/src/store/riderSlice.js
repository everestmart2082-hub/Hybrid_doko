import { createSlice } from '@reduxjs/toolkit';

const initialState = {
  data: [],
  loading: false,
  error: null,
};

const riderSlice = createSlice({
  name: 'rider',
  initialState,
  reducers: {
    setLoading: (state, action) => { state.loading = action.payload; },
    setError:   (state, action) => { state.error   = action.payload; },
    setData:    (state, action) => { state.data    = action.payload; },
    reset:      () => initialState,
  },
});

export const { setLoading, setError, setData, reset } = riderSlice.actions;
export default riderSlice.reducer;
