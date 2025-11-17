import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import './OrderDetailPage.css';
import Navbar from '../components/Home/Navbar';
const dummyOrder = {
  id: '123-456789',
  date: 'November 15, 2025',
  status: 'Shipped',
  estimatedDelivery: 'November 20, 2025',
  shippingAddress: {
    name: 'Jane Doe',
    street: '123 Main St',
    city: 'Anytown',
    state: 'CA',
    zip: '12345',
  },
  payment: {
    method: 'Visa',
    lastFour: '1234',
    billingAddress: {
      name: 'Jane Doe',
      street: '123 Main St',
      city: 'Anytown',
      state: 'CA',
      zip: '12345',
    }
  },
  items: [
    {
      id: 1,
      name: 'Modern E-Commerce T-Shirt',
      price: 29.99,
      imageUrl: 'https://via.placeholder.com/150/F5F5F5/333333?text=Product+1',
      quantity: 1,
    },
    {
      id: 2,
      name: 'Classic White T-Shirt',
      price: 25.00,
      imageUrl: 'https://via.placeholder.com/150/F5F5F5/333333?text=Product+2',
      quantity: 2,
    },
  ],
  summary: {
    subtotal: 79.99,
    shipping: 5.00,
    tax: 6.40,
    total: 91.39,
  },
  progress: {
    steps: ['Order Placed', 'Processing', 'Shipped', 'Delivered'],
    currentStep: 'Shipped',
  }
};
// --------------------

// Helper to format price
const formatPrice = (price) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(price);
};

// --- Main Page Component ---
const OrderDetailPage = () => {
  const { orderId } = useParams();
  const [order, setOrder] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    // --- Simulate API Fetch ---
    setIsLoading(true);
    setTimeout(() => {
      // In a real app, you'd fetch the order by orderId
      setOrder(dummyOrder);
      setIsLoading(false);
    }, 1000);
    // -------------------------
  }, [orderId]);

  // Renders a loading spinner
  const renderLoading = () => (
    <div className="order-detail-loader">
      <div className="loading-spinner"></div>
      <p>Loading Order Details...</p>
    </div>
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

  const { id, date, status, items, progress, summary, shippingAddress, payment } = order;
  const currentStepIndex = progress.steps.indexOf(progress.currentStep);

  return (
    <>
      <Navbar />
      <div className="order-detail-page-container">
        <div className="order-detail-content">
          <h1 className="order-detail-page-title">Order #{id}</h1>
          <div className="order-header-info">
            <span>Placed on {date}</span>
            <span className={`order-status-badge ${status.toLowerCase()}`}>
              {status}
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
                {items.map(item => (
                  <div key={item.id} className="detail-item-card">
                    <img src={item.imageUrl} alt={item.name} className="detail-item-image" />
                    <div className="detail-item-info">
                      <span className="detail-item-name">{item.name}</span>
                      <span className="detail-item-qty">Qty: {item.quantity}</span>
                    </div>
                    <span className="detail-item-price">{formatPrice(item.price * item.quantity)}</span>
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
                  <span>{formatPrice(summary.subtotal)}</span>
                </div>
                <div className="summary-row">
                  <span>Shipping</span>
                  <span>{formatPrice(summary.shipping)}</span>
                </div>
                <div className="summary-row">
                  <span>Tax</span>
                  <span>{formatPrice(summary.tax)}</span>
                </div>
                <div className="summary-total">
                  <strong>Total</strong>
                  <strong>{formatPrice(summary.total)}</strong>
                </div>
              </div>

              {/* Shipping Address */}
              <div className="summary-card">
                <h2>Shipping Address</h2>
                <p className="address-block">
                  <strong>{shippingAddress.name}</strong><br />
                  {shippingAddress.street}<br />
                  {shippingAddress.city}, {shippingAddress.state} {shippingAddress.zip}
                </p>
              </div>

              {/* Payment Method */}
              <div className="summary-card">
                <h2>Payment Method</h2>
                <p className="address-block">
                  <strong>{payment.method}</strong> ending in {payment.lastFour}
                </p>
              </div>

            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default OrderDetailPage;