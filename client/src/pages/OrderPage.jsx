import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './OrderPage.css';
import Navbar from '../components/Home/Navbar';
const dummyOrders = [
  {
    id: '123-456789',
    date: 'November 15, 2025',
    status: 'Delivered', // 'Delivered', 'Shipped', 'Processing'
    total: 134.98,
    items: [
      'https://via.placeholder.com/150/F5F5F5/333333?text=Product+1',
      'https://via.placeholder.com/150/F5F5F5/333333?text=Product+2',
    ]
  },
  {
    id: '123-987654',
    date: 'November 10, 2025',
    status: 'Shipped',
    total: 29.99,
    items: [
      'https://via.placeholder.com/150/F5F5F5/333333?text=Product+3',
    ]
  },
  {
    id: '123-111222',
    date: 'November 1, 2025',
    status: 'Processing',
    total: 79.99,
    items: [
      'https://via.placeholder.com/150/F5F5F5/333333?text=Product+4',
      'https://via.placeholder.com/150/F5F5F5/333333?text=Product+5',
      'https://via.placeholder.com/150/F5F5F5/333333?text=Product+6',
    ]
  },
];
// --------------------

// Helper to format price
const formatPrice = (price) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(price);
};

// --- Main Page Component ---
const OrderPage = ({ isLoggedIn, setIsLoggedIn }) => {
  const [orders, setOrders] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    // --- Simulate API Fetch ---
    setIsLoading(true);
    setTimeout(() => {
      // In a real app, you'd fetch orders for the logged-in user
      setOrders(dummyOrders);
      setIsLoading(false);
    }, 1000);
    // -------------------------
  }, []);

  // Renders a loading spinner
  const renderLoading = () => (
    <div className="order-loader">
      <div className="loading-spinner"></div>
      <p>Loading Your Orders...</p>
    </div>
  );

  // Renders if no orders are found
  const renderEmptyState = () => (
    <div className="orders-empty">
      <h2>You haven't placed any orders yet.</h2>
      <p>When you do, your orders will appear here.</p>
      <button className="primary-btn" onClick={() => navigate('/')}>
        Start Shopping
      </button>
    </div>
  );

  // Renders the list of order cards
  const renderOrderList = () => (
    <div className="order-list">
      {orders.map(order => (
        <div key={order.id} className="order-card">
          <div className="order-card-header">
            <div className="header-info">
              <span className="order-id">Order #{order.id}</span>
              <span className="order-date">Placed on {order.date}</span>
            </div>
            {/* Status Badge */}
            <span className={`order-status-badge ${order.status.toLowerCase()}`}>
              {order.status}
            </span>
          </div>
          
          <div className="order-card-body">
            {order.items.slice(0, 5).map((imgUrl, index) => ( // Show first 5 items
              <img 
                key={index}
                src={imgUrl} 
                alt={`Item ${index+1}`} 
                className="item-preview-image" 
              />
            ))}
            {order.items.length > 5 && (
              <div className="item-preview-more">+{order.items.length - 5} more</div>
            )}
          </div>

          <div className="order-card-footer">
            <span className="order-total">{formatPrice(order.total)}</span>
            <button 
              className="secondary-btn" 
              onClick={() => navigate(`/orders/${order.id}`)} // Link to specific order tracking
            >
              View Details
            </button>
          </div>
        </div>
      ))}
    </div>
  );

  return (
    <>
      <Navbar isLoggedIn={isLoggedIn} setIsLoggedIn={setIsLoggedIn} />
      <div className="order-page-container">
        <div className="order-content">
          <h1 className="order-page-title">My Orders</h1>
          {isLoading 
            ? renderLoading() 
            : (orders.length === 0 ? renderEmptyState() : renderOrderList())
          }
        </div>
      </div>
    </>
  );
};

export default OrderPage;