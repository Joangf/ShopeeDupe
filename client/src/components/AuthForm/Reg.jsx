import "../../pages/Login.css";
import AnimatedSubmitButton from "../AnimatedSubmitButton";
const Reg = ({formData ,handleSubmit, handleInputChange, isLoading, invalidSubmit }) => (
  <form onSubmit={handleSubmit} className="auth-form">
    <div className="form-row">
      <div className="form-group">
        <label htmlFor="firstName">First Name</label>
        <input
          type="text"
          id="firstName"
          name="firstName"
          value={formData.firstName}
          onChange={handleInputChange}
          required
          placeholder="First name"
        />
      </div>
      <div className="form-group">
        <label htmlFor="lastName">Last Name</label>
        <input
          type="text"
          id="lastName"
          name="lastName"
          value={formData.lastName}
          onChange={handleInputChange}
          required
          placeholder="Last name"
        />
      </div>
    </div>
    <div className="form-group">
      <label htmlFor="username">Username</label>
      <input
        type="text"
        id="username"
        name="username"
        value={formData.username}
        onChange={handleInputChange}
        required
        placeholder="Choose a username"
      />
    </div>
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
        placeholder="Create a password"
      />
    </div>
    <div className="form-group">
      <label htmlFor="confirmPassword">Confirm Password</label>
      <input
        type="password"
        id="confirmPassword"
        name="confirmPassword"
        value={formData.confirmPassword}
        onChange={handleInputChange}
        required
        placeholder="Confirm your password"
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
      {invalidSubmit && (
        <div className="error-message" style={{ color: "red" }}>
          Your email has been used by another user
        </div>
      )}
    </div>
    <AnimatedSubmitButton
      isLoading={isLoading}
      idleText="Create Account"
      loadingText="Creating Account..."
    />
  </form>
);
export default Reg;