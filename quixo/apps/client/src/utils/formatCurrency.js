export const formatNPR = (amount) =>
  new Intl.NumberFormat('ne-NP', { style: 'currency', currency: 'NPR' }).format(amount);