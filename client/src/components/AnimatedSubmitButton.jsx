const AnimatedSubmitButton = ({isLoading, idleText, loadingText}) => {
  
  return (
    <button type="submit" className="auth-button primary" disabled={isLoading}>
      {isLoading ? (
        <>
          <div className="loading-spinner"></div>
          {loadingText}
        </>
      ) : (
        idleText
      )}
    </button>
  );
};
export default AnimatedSubmitButton;
