import "../../pages/Login.css";
import AnimatedSubmitButton from "../AnimatedSubmitButton";
const OTP = ({formData ,handleSubmit, handleInputChange, isLoading, invalidSubmit, setActiveTab }) => (
  <form onSubmit={handleSubmit} className="auth-form">
    <div className="form-group">
      <p>
        We have sent a verification code to your email <i>{formData.email}</i>.
        Please enter the OTP to verify.
      </p>
      <label htmlFor="otp">OTP</label>
      <input
        type="otp"
        id="otp"
        name="otp"
        value={formData.otp}
        onChange={handleInputChange}
        required
        placeholder="Enter your OTP"
        style={{
          borderColor: invalidSubmit ? "red" : "",
        }}
      />
    </div>
    {invalidSubmit && (
      <div className="error-message" style={{ color: "red" }}>
        Invalid OTP.
      </div>
    )}
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
export default OTP;