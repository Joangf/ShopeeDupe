import { useEffect, useState } from "react";
import "./SellerCenter.css"; // We will create this next
const API_URL = import.meta.env.VITE_BACKEND_URL;
import ProductGrid from "../Home/ProductGrid.jsx";
import TickingSuccess from "../Notifications/TickingSuccess.jsx";
const CreateProductForm = ({ onClose, setProducts }) => {
  const [productData, setProductData] = useState({
    sellerId: localStorage.getItem('idUser'),
    name: "",
    barcode: "",
    brandname: "",
    description: "",
    price: 0,
    stockQuantity: 0,
    imageURL: ""
  });
  const [showSuccess, setShowSuccess] = useState(false);
  const handleChange = (e) => {
    setProductData({ ...productData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch(`${API_URL}/products`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(productData),
      });
      if (response.ok) {
        const data = await response.json();
        console.log("Product created:", data);
        setProducts(prevProducts => [...prevProducts, data.product]);
        setShowSuccess(true);
        setTimeout(() => {
          setShowSuccess(false);
          onClose();
        }, 2000);

      }
    } catch (error) {
      console.error("Failed to create product:", error);
    }
  };
  return (
    <div className="modal-backdrop">
      <TickingSuccess message="Product created successfully!" isVisible={showSuccess} />
      <form onSubmit={handleSubmit} className="product-form">
        <div className="modal-header">
          <h1>Create New Product</h1>
          <button type="button" className="close-product-form" onClick={onClose}>×</button>
        </div>
        {/* Name */}
        <div className="form-group">
          <label htmlFor="name">Name</label>
          <input
            type="text"
            id="name"
            name="name"
            value={productData.name}
            onChange={handleChange}
          />
        </div>
        {/* Barcode */}
        <div className="form-group">
          <label htmlFor="barcode">Barcode</label>
          <input
            type="text"
            id="barcode"
            name="barcode"
            value={productData.barcode}
            onChange={handleChange}
          />
        </div>
        {/* Brand Name */}
        <div className="form-group">
          <label htmlFor="brandname">Brand Name</label>
          <input
            type="text"
            id="brandname"
            name="brandname"
            value={productData.brandname}
            onChange={handleChange}
          />
        </div>
        {/* Description */}
        <div className="form-group">
          <label htmlFor="description">Description</label>
          <textarea
            id="description"
            name="description"
            className="product-textarea"
            value={productData.description}
            onChange={handleChange}
          />
        </div>
        {/* Price */}
        <div className="form-group">
          <label htmlFor="price">Price</label>
          <input
            type="number"
            id="price"
            name="price"
            value={productData.price}
            onChange={handleChange}
          />
        </div>
        {/* Stock Quantity */}
        <div className="form-group">
          <label htmlFor="stockQuantity">Stock Quantity</label>
          <input
            type="number"
            id="stockQuantity"
            name="stockQuantity"
            value={productData.stockQuantity}
            onChange={handleChange}
          />
        </div>
        {/* Image URL */}
        <div className="form-group">
          <label htmlFor="imageURL">Image URL</label>
          <input
            type="text"
            id="imageURL"
            name="imageURL"
            value={productData.imageURL}
            onChange={handleChange}
          />
          <button type="submit" className="primary-btn">Create Product</button>
        </div>
      </form>
    </div>
  )
};
const SellerCenter = ({ sellerData, setSellerData }) => {
  // State for the registration form
  const [shopData, setShopData] = useState({
    businessName: "",
    businessAddress: "",
  });
  const [products, setProducts] = useState([]);
  const [isCreateProductOpen, setIsCreateProductOpen] = useState(false);
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
  useEffect(() => {
    const fetchSellerProducts = async () => {
      try {
        const userId = localStorage.getItem('idUser');
        const response = await fetch(`${API_URL}/products/seller/${userId}`);
        if (response.ok) {
          const data = await response.json();
          setProducts(data.products);
        }
      } catch (error) {
        console.error("Failed to fetch seller products:", error);
      }
    };
    fetchSellerProducts();
  }, [])
  // --- VIEW 1: USER IS ALREADY A SELLER (DASHBOARD) ---
  if (sellerData) {
    return (
      <>
      {isCreateProductOpen && (<CreateProductForm onClose={() => setIsCreateProductOpen(false)} setProducts={setProducts} />
      )}
      <div className="profile-main seller-dashboard">
        <div className="profile-header">
          <h1>{sellerData.businessName}</h1>
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

        <button className="primary-btn" onClick={() => setIsCreateProductOpen(true)}>Create Product</button>
        <ProductGrid products={products} pad2="0px" pad1="0px"/>
      </div>
      </>
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