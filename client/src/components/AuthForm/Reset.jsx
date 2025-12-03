import "../../pages/Login.css";
import AnimatedSubmitButton from "../AnimatedSubmitButton";
const Reset = ({formData ,handleSubmit, handleInputChange, isLoading, invalidSubmit, setActiveTab }) => (
  <form onSubmit={handleSubmit} className="auth-form">
    <div className="form-group">
      <p>
        We have sent a verification code to your email <i>{formData.email}</i>.
        Please enter the Token to verify.
      </p>
      <label htmlFor="otp">Token</label>
      <input
        type="otp"
        id="otp"
        name="otp"
        value={formData.otp}
        onChange={handleInputChange}
        required
        placeholder="Enter your Token"
        style={{
          borderColor: invalidSubmit ? "red" : "",
        }}
      />
      {invalidSubmit && (
        <div className="error-message" style={{ color: "red" }}>
          Invalid Token.
        </div>
      )}
    </div>
    <div className="form-group">
      <label htmlFor="password">New Password</label>
      <input
        type="password"
        id="password"
        name="password"
        value={formData.password}
        onChange={handleInputChange}
        required
        placeholder="Create a new password"
      />
    </div>
    <div className="form-group">
      <label htmlFor="confirmPassword">New Confirm Password</label>
      <input
        type="password"
        id="confirmPassword"
        name="confirmPassword"
        value={formData.confirmPassword}
        onChange={handleInputChange}
        required
        placeholder="Confirm your new password "
        style={{
          borderColor:
            formData.confirmPassword &&
            formData.password !== formData.confirmPassword
              ? "red"
              : "",
        }}
      />
      {formData.confirmPassword &&
        formData.password !== formData.confirmPassword && (
          <div className="error_message" style={{ color: "red" }}>
            Passwords do not match
          </div>
        )}
    </div>
    <AnimatedSubmitButton
      isLoading={isLoading}
      idleText="Verify"
      loadingText="Verifying..."
    />
    <button
      type="button"
      className="back-to-login-link"
      onClick={() => setActiveTab("login")}
    >
      Back to Login
    </button>
  </form>
);
export default Reset;
