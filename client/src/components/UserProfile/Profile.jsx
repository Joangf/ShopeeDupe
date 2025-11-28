import "../../pages/UserProfilePage.css";

const Profile = ({
  formData,
  handleInputChange,
  handleSubmit,
  setActiveDelete,
}) => {
  return (
    <main className="profile-main">
      <div className="profile-header">
        <h1>Profile</h1>
      </div>

      <div className="profile-content">
        <form onSubmit={handleSubmit} className="profile-form">
          {/* Name */}
          <div className="form-group">
            <label htmlFor="fullName">Full Name</label>
            <input
              type="text"
              id="fullName"
              name="fullName"
              value={formData.fullName}
              onChange={handleInputChange}
            />
          </div>

          {/* Row 2: Gender and DOB */}
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="gender">Gender</label>
              <input
                id="gender"
                name="gender"
                value={formData.gender}
                onChange={handleInputChange}
                className="form-select" // Ensure you have styles for this or reuse input styles
              >
              </input>
            </div>
            <div className="form-group">
              <label htmlFor="dateOfBirth">Date of Birth</label>
              <input
                type="date"
                id="dateOfBirth"
                name="dateOfBirth"
                value={formData.dateOfBirth}
                onChange={handleInputChange}
              />
            </div>
          </div>

          {/* National ID */}
          <div className="form-group">
            <label htmlFor="nationalId">National ID</label>
            <input
              type="text"
              id="nationalId"
              name="nationalId"
              value={formData.nationalId}
              onChange={handleInputChange}
            />
          </div>

          {/* Email */}
          <div className="form-group">
            <label htmlFor="email">Email Address</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
            />
          </div>

          {/* Phone Number */}
          <div className="form-group">
            <label htmlFor="phoneNumber">Phone Number</label>
            <input
              type="tel"
              id="phoneNumber"
              name="phoneNumber"
              value={formData.phoneNumber}
              onChange={handleInputChange}
            />
          </div>

          {/* Address */}
          <div className="form-group">
            <label htmlFor="address">Address</label>
            <input
              type="text"
              id="address"
              name="address"
              value={formData.address}
              onChange={handleInputChange}
            />
          </div>

          {/* Buttons */}
          <div className="profile-form-button">
            <button type="submit" className="save-button primary-btn">
              Save Changes
            </button>
            <button
              type="button"
              className="delete-button primary-btn"
              onClick={() => setActiveDelete(true)}
            >
              Delete Account
            </button>
          </div>
        </form>

        <aside className="profile-picture-section">
          <h2 className="section-title">Profile Picture</h2>
          <div className="profile-picture-wrapper">
            <img
              src="https://api.builder.io/api/v1/image/assets/TEMP/684c1d3085f1617fc628757c78b96af3f1430943?width=600"
              alt="Profile"
              className="profile-picture"
            />
            <button className="edit-picture-button secondary-btn">
              <span>Edit Picture</span>
            </button>
          </div>
        </aside>
      </div>
    </main>
  );
};

export default Profile;