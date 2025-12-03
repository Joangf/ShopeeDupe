import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import './OrderDetailPage.css';
import Navbar from '../components/Home/Navbar';
import TickingSuccess from '../components/Notifications/TickingSuccess';
const API_URL = import.meta.env.VITE_BACKEND_URL;

// Helper to format price
const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(price);
};

// --- Main Page Component ---
const progress = {
  steps: ['Pending', 'Processing', 'Shipped', 'Delivered'],
};
const OrderDetailPage = ({ isLoggedIn, setIsLoggedIn }) => {
  const { orderId } = useParams();
  const [order, setOrder] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [showSuccess, setShowSuccess] = useState(false);
  const navigate = useNavigate();
  const [currentStepIndex, setCurrentStepIndex] = useState(0);
  const [formData, setFormData] = useState({
    paymentMethod: '',
  });
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prevData => ({
      ...prevData,
      [name]: value,
    }));
  };
  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch(`${API_URL}/order/payment`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          userId: localStorage.getItem('idUser'),
          orderId: orderId,
          paymentMethod: formData.paymentMethod,
        }),
      });
      if (response.ok) {
        setShowSuccess(true);
        setOrder(prevOrder => ({
          ...prevOrder,
          paymentMethod: formData.paymentMethod,
          status: 'Processing',
        }));
        setCurrentStepIndex(1);
        setTimeout(() => setShowSuccess(false), 2000);
      } 
    } catch (error) {
      console.error("Failed to update payment method:", error);
    }
  };
  useEffect(() => {
    // --- Simulate API Fetch ---
    setIsLoading(true);
    const fetchOrderDetails = async () => {
      try {
        const response = await fetch(`${API_URL}/order/details/${orderId}`);
        if (response.ok) {
          const orderData = await response.json();
          setOrder(orderData);
          setCurrentStepIndex(progress.steps.indexOf(orderData.status));
        }
      } catch (error) {
        console.error("Failed to fetch order details:", error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchOrderDetails();
  }, [orderId]);

  // Renders a loading spinner
  const renderLoading = () => (
    <>
      <Navbar isLoggedIn={isLoggedIn} setIsLoggedIn={setIsLoggedIn} />
      <div className="order-detail-loader">
        <div className="loading-spinner"></div>
        <p>Loading Order Details...</p>
      </div>
    </>
  );

  if (isLoading) {
    return (
      <div className="order-detail-page-container">
        {renderLoading()}
      </div>
    );
  }

  if (!order) {
    return (
      <div className="order-detail-page-container">
        <p>Order not found.</p>
      </div>
    );
  }


  return (
    <>
      {showSuccess && <TickingSuccess message="Payment method updated successfully!" isVisible={true} />}
      <Navbar isLoggedIn={isLoggedIn} setIsLoggedIn={setIsLoggedIn} />
      <div className="order-detail-page-container">
        <div className="order-detail-content">
          <h1 className="order-detail-page-title">Order #{orderId}</h1>
          <div className="order-header-info">
            <span>Placed on {order.orderDate.split('T')[0]}</span>
            <span className={`order-status-badge ${order.status.toLowerCase()}`}>
              {order.status}
            </span>
          </div>

          {/* --- Progress Bar --- */}
          <div className="status-progress-bar">
            {progress.steps.map((step, index) => (
              <div
                key={step}
                className={`progress-step ${index <= currentStepIndex ? 'active' : ''}`}
              >
                <div className="progress-dot"></div>
                <div className="progress-label">{step}</div>
              </div>
            ))}
          </div>

          {/* --- Main 2-Column Layout --- */}
          <div className="order-detail-layout">
            
            {/* --- Left Column (Items) --- */}
            <div className="order-items-column">
              <h2>Items in this Order</h2>
              <div className="order-item-list">
                {order.products.map(item => (
                  <div key={item.ProductID} className="detail-item-card" onClick={() => navigate(`/product/${item.ProductID}`)}>
                    <img src={item.ImageURL} alt={item.Name} className="detail-item-image" />
                    <div className="detail-item-info">
                      <span className="detail-item-name">{item.Name}</span>
                      <span className="detail-item-qty">Qty: {item.Quantity}</span>
                    </div>
                    <span className="detail-item-price">{formatPrice(item.Price * item.Quantity)}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* --- Right Column (Summary) --- */}
            <div className="order-summary-column">
              {/* Financial Summary */}
              <div className="summary-card">
                <h2>Order Summary</h2>
                <div className="summary-row">
                  <span>Subtotal</span>
                  <span>{formatPrice(order.totalAmount)}</span>
                </div>
                <div className="summary-row">
                  <span>Shipping</span>
                  <span>{formatPrice(0)}</span>
                </div>
                <div className="summary-row">
                  <span>Tax</span>
                  <span>{formatPrice(0)}</span>
                </div>
                <div className="summary-total">
                  <strong>Total</strong>
                  <strong>{formatPrice(order.totalAmount)}</strong>
                </div>
              </div>

              {/* Shipping Address */}
              <div className="summary-card">
                <h2>Shipping Address</h2>
                <p className="address-block">
                  <strong>{order.shippingAddress}</strong><br />
                  {/* {shippingAddress.street}<br />
                  {shippingAddress.city}, {shippingAddress.state} {shippingAddress.zip} */}
                </p>
              </div>

              {/* Payment Method */}
              <div className="summary-card">
                <h2>Payment Method</h2>
                {order.paymentMethod ? 
                (
                  <p className="address-block">
                    <strong>{order.paymentMethod}</strong>
                  </p>
                ) : 
                (
                  <form action="submit" onSubmit={handleSubmit}>
                    <div className="form-group">
                      <input
                        type="text"
                        id="paymentMethod"
                        name="paymentMethod"
                        value={formData.paymentMethod}
                        onChange={handleInputChange}
                        placeholder="Enter payment method"
                      />
                    <button type="submit" className="primary-btn">Submit</button>
                    </div>
                  </form>
                )
                  }

              </div>

            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default OrderDetailPage;