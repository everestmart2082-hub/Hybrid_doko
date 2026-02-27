import { useState, useEffect } from 'react';
export const useLocation = () => {
  const [coords, setCoords] = useState(null);
  useEffect(() => {
    const id = navigator.geolocation.watchPosition(
      (pos) => setCoords({ lat: pos.coords.latitude, lng: pos.coords.longitude }),
      (err) => console.error(err)
    );
    return () => navigator.geolocation.clearWatch(id);
  }, []);
  return coords;
};