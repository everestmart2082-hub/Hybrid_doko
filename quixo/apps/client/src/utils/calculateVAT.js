export const addVAT = (price, rate = 0.13) => +(price * (1 + rate)).toFixed(2);
export const getVAT = (price, rate = 0.13) => +(price * rate).toFixed(2);