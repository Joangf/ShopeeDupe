import "../../pages/Login.css";
import AnimatedSubmitButton from "../AnimatedSubmitButton";

const Reg = ({ formData, handleSubmit, handleInputChange, isLoading, invalidSubmit }) => (
  <form onSubmit={handleSubmit} className="auth-form">
    {/* First Name and Last Name in a row */}

    <div className="form-group">
      <label htmlFor="fullName">Full Name</label>
      <input
        type="text"
        id="fullName"
        name="fullName"
        value={formData.fullName}
        onChange={handleInputChange}
        required
        placeholder="Enter your full name"
      />
    </div>
    <div className="form-row">
      <div className="form-group">
        <label htmlFor="gender">Gender</label>
        <input
          id="gender"
          name="gender"
          value={formData.gender}
          onChange={handleInputChange}
          placeholder="Enter your gender"
          required
        />
      </div>
      <div className="form-group">
        <label htmlFor="dateOfBirth">Date of Birth</label>
        <input
          type="date"
          id="dateOfBirth"
          name="dateOfBirth"
          value={formData.dateOfBirth}
          onChange={handleInputChange}
          required
        />
      </div>
    </div>

    {/* National ID (new) */}
    <div className="form-group">
      <label htmlFor="nationalId">National ID</label>
      <input
        type="text"
        id="nationalId"
        name="nationalId"
        value={formData.nationalId}
        onChange={handleInputChange}
        required
        placeholder="Enter your national ID"
      />
    </div>

    {/* Email */}
    <div className="form-group">
      <label htmlFor="email">Email</label>
      <input
        type="text"
        id="email"
        name="email"
        value={formData.email}
        onChange={handleInputChange}
        required
        placeholder="Enter your email"
      />
    </div>

    {/* Phone Number (new) */}
    <div className="form-group">
      <label htmlFor="phoneNumber">Phone Number</label>
      <input
        type="tel"
        id="phoneNumber"
        name="phoneNumber"
        value={formData.phoneNumber}
        onChange={handleInputChange}
        required
        placeholder="Enter your phone number"
      />
    </div>

    {/* Address (new) */}
    <div className="form-group">
      <label htmlFor="address">Address</label>
      <input
        type="text"
        id="address"
        name="address"
        value={formData.address}
        onChange={handleInputChange}
        required
        placeholder="Enter your address"
      />
    </div>

    {/* Password */}
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

    {/* Confirm Password with validation */}
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
          {invalidSubmit}
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