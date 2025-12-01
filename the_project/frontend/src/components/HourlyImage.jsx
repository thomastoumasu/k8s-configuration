import { useState } from 'react';
import fallback from '../assets/defaultImage.jpg';

const HourlyImage = () => {
  const style = { width: 350 };
  const src = '/shared/hourlyImage.jpg';
  const [imagePath, setImagePath] = useState(src);
  const onError = () => {
    console.log(
      `hourly image not found - defaulting to assets image. Check the storage mount at ${src}`
    );
    setImagePath(fallback);
  };
  return (
    <img
      style={style}
      src={imagePath ? imagePath : fallback}
      onError={onError}
      alt="hourly image"
    />
  );
};

export default HourlyImage;
