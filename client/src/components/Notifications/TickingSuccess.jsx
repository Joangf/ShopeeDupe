import { useState, useEffect } from 'react';
import './TickingSuccess.css';

const TickingSuccess = ({ 
  isVisible = false, 
  message = "Success!", 
}) => {
  const [showTick, setShowTick] = useState(false);
  const [showMessage, setShowMessage] = useState(false);
  useEffect(() => {
    if (isVisible) {
      // Show tick animation first
      const tickTimer = setTimeout(() => {
        setShowTick(true);
      }, 100);

      // Show message after tick animation
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
    <div className="ticking-success-overlay">
      <div className="ticking-success-container">
        <div className={`tick-circle ${showTick ? 'animate' : ''}`}>
          <svg className="tick-svg" viewBox="0 0 52 52">
            <circle 
              className="tick-circle-bg" 
              cx="26" 
              cy="26" 
              r="25" 
              fill="none"
            />
            <path 
              className="tick-check" 
              fill="none" 
              d="M14.1 27.2l7.1 7.2 16.7-16.8"
            />
          </svg>
        </div>
        <div className={`success-message ${showMessage ? 'show' : ''}`}>
          {message}
        </div>
        <div className={`redirect-info ${showMessage ? 'show' : ''}`}>
          Redirecting...
        </div>
      </div>
    </div>
  );
};

export default TickingSuccess;
