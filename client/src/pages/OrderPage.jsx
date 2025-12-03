import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './OrderPage.css';
import Navbar from '../components/Home/Navbar';
const API_URL = import.meta.env.VITE_BACKEND_URL;


// Helper to format price
const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
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
    const fetchOrders = async () => {
      try {
        const response = await fetch(`${API_URL}/order/user/${localStorage.getItem('idUser')}`);
        if (response.ok) {
          const orders = await response.json();
          setOrders(orders); // Assuming API returns { orders: [...] }
        }
      } catch (error) {
        console.error('Error fetching orders:', error);
      } finally {
        setIsLoading(false);
      }
    }
    fetchOrders();
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
              <span className="order-id">Order #{order.OrderID}</span>
              <span className="order-date">Placed on {order.OrderDate.split('T')[0]}</span>
            </div>
            {/* Status Badge */}
            <span className={`order-status-badge ${order.Status.toLowerCase()}`}>
              {order.Status}
            </span>
          </div>
          
          <div className="order-card-body">
            {/* {order.items.slice(0, 5).map((imgUrl, index) => ( // Show first 5 items
              <img 
                key={index}
                src={imgUrl} 
                alt={`Item ${index+1}`} 
                className="item-preview-image" 
              />
            ))}
            {order.items.length > 5 && (
              <div className="item-preview-more">+{order.items.length - 5} more</div>
            )} */}
          </div>

          <div className="order-card-footer">
            <span className="order-total">{formatPrice(order.TotalAmount)}</span>
            <button 
              className="secondary-btn" 
              onClick={() => navigate(`/orders/${order.OrderID}`)} // Link to specific order tracking
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