import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Cart.css";
import Navbar from "../components/Home/Navbar";
const API_URL = import.meta.env.VITE_BACKEND_URL;


// Helper to format price
const formatPrice = (price) => {
  return new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
  }).format(price);
};

const Cart = ({ isLoggedIn, setIsLoggedIn }) => {
  const [cartItems, setCartItems] = useState([]);
  const [formData, setFormData] = useState({
    address: "",
  });
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();

  // --- Cart Logic ---
  const handleInputChange = (e) => {
    setFormData((prevData) => ({
      ...prevData,
      address: e.target.value,
    }));
  }
  const handleQuantityChange = async (id, amount) => {
    setCartItems(
      (prevItems) =>
        prevItems
          .map((item) =>
            item.ProductID === id
              ? { ...item, quantity: item.quantity + amount }
              : item
          )
          .filter((item) => item.quantity > 0) // Remove if quantity hits 0 (optional)
    );
    try {
      const quantity = cartItems.find(item => item.ProductID === id).quantity;
      const userId = localStorage.getItem('idUser');
      const response = await fetch(`${API_URL}/cart/update`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          userId: userId,
          productId: id,
          quantity: quantity + amount,
        }),
      });
    } catch (error) {
      console.error('Error updating cart:', error);
    }
  };

  const handleRemoveItem = (id) => {
    setCartItems((prevItems) => prevItems.filter((item) => item.ProductID !== id));
  };
  const handleCheckout = async (e) => {
    e.preventDefault();
    try {
      const userId = localStorage.getItem('idUser');
      const response = await fetch(`${API_URL}/order/create`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          userId: userId,
          shipmentAddress: formData.address,
        }),
      });
      if (response.ok) {
        const data = await response.json();
        navigate(`/orders/${data.order.OrderID}`);
      } else {
        console.error("Failed to create order");
      }
    } catch (error) {
      console.error("Error during checkout:", error);
    }
  };
  const calculateSubtotal = () => {
    return cartItems.reduce(
      (total, item) => total + item.Price * item.quantity,
      0
    );
  };

  const subtotal = calculateSubtotal();
  // Example shipping/tax. You would calculate this.
  const shipping = 0;
  const tax = 0;
  const total = subtotal + shipping + tax;

  // --- Render Functions ---
  const renderLoading = () => (
    <div className="order-loader">
      <div className="loading-spinner"></div>
      <p>Loading Your Cart...</p>
    </div>
  );

  const renderEmptyCart = () => (
    <div className="cart-empty">
      <h2>Your cart is empty.</h2>
      <p>Looks like you haven't added anything to your cart yet.</p>
      <button className="primary-btn" onClick={() => navigate("/")}>
        Continue Shopping
      </button>
    </div>
  );

  const renderCart = () => (
    <div className="cart-layout">
      {/* Left Column: Cart Items */}
      <div className="cart-items-list">
        {cartItems.map((item) => (
          <div key={item.ProductID} className="cart-item-card">
            <img
              src={item.ImageURL}
              alt={item.Name}
              className="cart-item-image"
            />
            <div className="cart-item-details">
              <h3 className="cart-item-name">{item.Name}</h3>
              <p className="cart-item-price">{formatPrice(item.Price)}</p>
            </div>
            <div className="cart-item-actions">
              <div className="quantity-selector">
                <button
                  onClick={() => handleQuantityChange(item.ProductID, -1)}
                  title="Decrease quantity"
                >
                  -
                </button>
                <span>{item.quantity}</span>
                <button
                  onClick={() => handleQuantityChange(item.ProductID, 1)}
                  title="Increase quantity"
                >
                  +
                </button>
              </div>
              <button
                className="remove-button"
                onClick={() => handleRemoveItem(item.ProductID)}
              >
                Remove
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Right Column: Order Summary */}
      <div className="cart-summary">
        <h2 className="summary-title">Order Summary</h2>
        <div className="summary-row">
          <span>Subtotal</span>
          <span>{formatPrice(subtotal)}</span>
        </div>
        <div className="summary-row">
          <span>Shipping</span>
          <span>{formatPrice(shipping)}</span>
        </div>
        <div className="summary-row">
          <span>Estimated Tax</span>
          <span>{formatPrice(tax)}</span>
        </div>
        <div className="summary-total">
          <strong>Total</strong>
          <strong>{formatPrice(total)}</strong>
        </div>
        <form action="submit" onSubmit={handleCheckout}>
          <div className="form-group">

            <input
              type="address"
              id="address"
              name="address"
              value={formData.address}
              onChange={handleInputChange}
              required
              placeholder="Enter your address for delivery"
              style={{
                marginTop: "15px",
              }}
            />
            <button
              className="checkout-button primary-btn"
              type="submit">
              Proceed to Checkout
            </button>
          </div>
        </form>


      </div>
    </div>
  );
  useEffect(() => {
    const fetchCartItems = async () => {
      setIsLoading(true);
      try {
        const userId = localStorage.getItem('idUser');
        const response = await fetch(`${API_URL}/cart/${userId}`);
        if (response.ok) {
          const data = await response.json();
          setCartItems(data);
        }
        
      } catch (error) {
        console.error("Failed to fetch cart items:", error);
      } finally {
        setIsLoading(false);
      }
    }
    fetchCartItems();
  }, [])
  return (
    <>
      <Navbar isLoggedIn={isLoggedIn} setIsLoggedIn={setIsLoggedIn} />
      <div className="cart-page-container">
        <div className="cart-content">
          <h1 className="cart-page-title">SHOPPING CART</h1>
          {isLoading ? renderLoading() : (cartItems.length === 0 ? renderEmptyCart() : renderCart())}
        </div>
      </div>
    </>
  );
};

export default Cart;
