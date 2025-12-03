import { useState, useEffect } from 'react';
import './TickingFail.css';

const TickingFail = ({ 
  isVisible = false, 
  message = "Failed", 
}) => {
  const [showTick, setShowTick] = useState(false);
  const [showMessage, setShowMessage] = useState(false);
  useEffect(() => {
    if (isVisible) {
      // Show x animation first
      const tickTimer = setTimeout(() => {
        setShowTick(true);
      }, 100);

      // Show message after x animation
      const messageTimer = setTimeout(() => {
        setShowMessage(true);
      }, 400);

      return () => {
        clearTimeout(tickTimer);
        clearTimeout(messageTimer);
      };
    } else {
      setShowTick(false);
      setShowMessage(false);
    }
  }, [isVisible]);

  if (!isVisible) {
    return null;
  }

  return (
    <div className="ticking-fail-overlay">
      <div className="ticking-fail-container">
        <div className={`x-circle ${showTick ? 'animate' : ''}`}>
          <svg className="x-svg" viewBox="0 0 52 52">
            <circle 
              className="x-circle-bg" 
              cx="26" 
              cy="26" 
              r="25" 
              fill="none"
            />
            {/* Changed from a checkmark path to two paths that form an 'X' */}
            <path 
              className="x-check" 
              fill="none" 
              d="M16 16 L36 36"
            />
            <path 
              className="x-check" 
              fill="none" 
              d="M36 16 L16 36"
            />
          </svg>
        </div>
        <div className={`fail-message ${showMessage ? 'show' : ''}`}>
          {message}
        </div>
        <div className={`redirect-info ${showMessage ? 'show' : ''}`}>
          Redirecting...
        </div>
      </div>
    </div>
  );
};

export default TickingFail;