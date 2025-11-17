import "../../pages/Login.css";
import AnimatedSubmitButton from "../AnimatedSubmitButton";
const Log = ({formData ,handleSubmit, handleInputChange, isLoading, invalidSubmit, setActiveTab }) => (
  <form onSubmit={handleSubmit} className="auth-form">
    <div className="form-group">
      <label htmlFor="email">Email</label>
      <input
        type="email"
        id="email"
        name="email"
        value={formData.email}
        onChange={handleInputChange}
        required
        placeholder="Enter your email"
      />
    </div>
    <div className="form-group">
      <label htmlFor="password">Password</label>
      <input
        type="password"
        id="password"
        name="password"
        value={formData.password}
        onChange={handleInputChange}
        required
        placeholder="Enter your password"
      />
    </div>
    {invalidSubmit && (
      <div className="error-message" style={{ color: "red" }}>
        Email or password is incorrect.
      </div>
    )}
    <AnimatedSubmitButton
      isLoading={isLoading}
      idleText="Login"
      loadingText="Logging in..."
    />
    <button
      type="button"
      className="forgot-password-link"
      onClick={() => setActiveTab("forgot")}
    >
      Forgot Password?
    </button>
  </form>
);
export default Log;