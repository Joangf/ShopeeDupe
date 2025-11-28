import "../../pages/UserProfilePage.css";
const DeleteAccountBox = ({ onCancel, onConfirm }) => {
  return (
    <div className="confirm-overlay">
      <div className="confirm-modal">
        <div className="confirm-icon">
          <svg
            width="48"
            height="48"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M12 2L1 21H23L12 2ZM12 18C11.45 18 11 17.55 11 17V15C11 14.45 11.45 14 12 14C12.55 14 13 14.45 13 15V17C13 17.55 12.55 18 12 18ZM13 12H11V8H13V12Z"
              fill="#B83B5E"
            />
          </svg>
        </div>
        <div className="confirm-content">
          <h1 className="confirm-title">Confirm Account Deletion</h1>
          <p className="confirm-text">
            Are you sure you want to permanently delete your account? This
            action cannot be undone.
          </p>
        </div>
        <div className="confirm-actions">
          <button
            type="button"
            className="action-btn neutral-btn"
            onClick={onCancel}
          >
            No, Go Back
          </button>
          <button
            type="button"
            className="action-btn destructive-btn"
            onClick={onConfirm}
          >
            Yes, I'm Sure
          </button>
        </div>
      </div>
    </div>
  );
};

export default DeleteAccountBox;