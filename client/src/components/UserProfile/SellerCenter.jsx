import { useState } from "react";
import "./SellerCenter.css"; // We will create this next
const API_URL = import.meta.env.VITE_BACKEND_URL;
const SellerCenter = ({ sellerData, setSellerData }) => {
  // State for the registration form
  const [shopData, setShopData] = useState({
    businessName: "",
    businessAddress: "",
  });

  const handleChange = (e) => {
    setShopData({ ...shopData, [e.target.name]: e.target.value });
  };

  const handleRegister = async (e) => {
    e.preventDefault();
    const userId = localStorage.getItem('idUser');
    try {
      const response = await fetch(`${API_URL}/auth/register/seller/${userId}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(shopData),
      });
      if (response.ok) {
        setSellerData(true);
      }
    } catch (error) {
      console.error("Registration failed:", error);
    }
  };

  // --- VIEW 1: USER IS ALREADY A SELLER (DASHBOARD) ---
  if (sellerData) {
    return (
      <div className="profile-main seller-dashboard">
        <div className="profile-header">
          <h1>Seller Dashboard</h1>
        </div>
        
        <div className="dashboard-stats">
            <div className="stat-card">
                <span className="stat-label">Total Revenue</span>
                <span className="stat-value">$0.00</span>
            </div>
            <div className="stat-card">
                <span className="stat-label">Orders</span>
                <span className="stat-value">0</span>
            </div>
            <div className="stat-card">
                <span className="stat-label">Products</span>
                <span className="stat-value">0</span>
            </div>
        </div>

        <div className="empty-state-dashboard">
            <p>You haven't listed any products yet.</p>
            <button className="primary-btn">Create Product</button>
        </div>
      </div>
    );
  }

  // --- VIEW 2: USER IS NOT A SELLER (REGISTRATION LANDING) ---
  return (
    <div className="profile-main seller-registration">
      {/* Hero Section */}
      <div className="seller-hero">
        <div className="hero-content">
          <h2 className="hero-title">Become a Supplier</h2>
          <p className="hero-subtitle">
            Expand your industrial footprint. Join the network of top-tier suppliers today.
          </p>
        </div>
        <div className="hero-badge">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z" fill="#1A1A1A"/>
            </svg>
        </div>
      </div>

      {/* Benefits Grid */}
      <div className="seller-benefits">
        <div className="benefit-item">
            <span className="benefit-icon">🚀</span>
            <h3>High Visibility</h3>
            <p>Reach thousands of industrial buyers instantly.</p>
        </div>
        <div className="benefit-item">
            <span className="benefit-icon">🛡️</span>
            <h3>Secure Trade</h3>
            <p>Guaranteed payments and verified partners.</p>
        </div>
        <div className="benefit-item">
            <span className="benefit-icon">📈</span>
            <h3>Analytics</h3>
            <p>Real-time data to optimize your supply chain.</p>
        </div>
      </div>

      <div className="divider"></div>

      {/* Registration Form */}
      <div className="registration-section">
        <div className="profile-header">
          <h1>Shop Registration</h1>
        </div>
        
        <form className="profile-form" onSubmit={handleRegister}>
          <div className="form-group">
            <label>Bussiness Name</label>
            <input
              type="text"
              name="businessName"
              placeholder="e.g. Apex Industrial Solutions"
              value={shopData.businessName}
              onChange={handleChange}
              required
            />
          </div>

          <div className="form-group">
            <label>Bussiness Address</label>
            <input
              type="text"
              name="businessAddress"
              placeholder="Warehouse location..."
              value={shopData.businessAddress}
              onChange={handleChange}
              required
            />
          </div>

          <div className="profile-form-button">
            <button type="submit" className="primary-btn register-btn">
              Register Shop
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default SellerCenter;