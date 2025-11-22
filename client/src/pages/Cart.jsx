import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Cart.css";
import Navbar from "../components/Home/Navbar";
// Dummy data - replace this with your actual cart state
const initialCartItems = [
  {
    id: 1,
    name: "Classic White T-Shirt",
    price: 25.0,
    imageUrl: "https://via.placeholder.com/150/F5F5F5/333333?text=Product+1",
    quantity: 1,
  },
  {
    id: 2,
    name: "Modern Blue Jeans",
    price: 79.99,
    imageUrl: "https://via.placeholder.com/150/F5F5F5/333333?text=Product+2",
    quantity: 2,
  },
];

// Helper to format price
const formatPrice = (price) => {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  }).format(price);
};

const Cart = () => {
  const [cartItems, setCartItems] = useState(initialCartItems);
  const navigate = useNavigate();

  // --- Cart Logic ---

  const handleQuantityChange = (id, amount) => {
    setCartItems(
      (prevItems) =>
        prevItems
          .map((item) =>
            item.id === id
              ? { ...item, quantity: Math.max(1, item.quantity + amount) } // Prevent quantity < 1
              : item
          )
          .filter((item) => item.quantity > 0) // Remove if quantity hits 0 (optional)
    );
  };

  const handleRemoveItem = (id) => {
    setCartItems((prevItems) => prevItems.filter((item) => item.id !== id));
  };

  const calculateSubtotal = () => {
    return cartItems.reduce(
      (total, item) => total + item.price * item.quantity,
      0
    );
  };

  const subtotal = calculateSubtotal();
  // Example shipping/tax. You would calculate this.
  const shipping = subtotal > 0 ? 5.0 : 0;
  const tax = subtotal * 0.08;
  const total = subtotal + shipping + tax;

  // --- Render Functions ---

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
          <div key={item.id} className="cart-item-card">
            <img
              src={item.imageUrl}
              alt={item.name}
              className="cart-item-image"
            />
            <div className="cart-item-details">
              <h3 className="cart-item-name">{item.name}</h3>
              <p className="cart-item-price">{formatPrice(item.price)}</p>
            </div>
            <div className="cart-item-actions">
              <div className="quantity-selector">
                <button
                  onClick={() => handleQuantityChange(item.id, -1)}
                  title="Decrease quantity"
                >
                  -
                </button>
                <span>{item.quantity}</span>
                <button
                  onClick={() => handleQuantityChange(item.id, 1)}
                  title="Increase quantity"
                >
                  +
                </button>
              </div>
              <button
                className="remove-button"
                onClick={() => handleRemoveItem(item.id)}
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
        <button
          className="checkout-button primary-btn"
          onClick={() => navigate("/checkout")}
        >
          Proceed to Checkout
        </button>
      </div>
    </div>
  );

  return (
    <>
      <Navbar />
      <div className="cart-page-container">
        <div className="cart-content">
          <h1 className="cart-page-title">SHOPPING CART</h1>
          {cartItems.length === 0 ? renderEmptyCart() : renderCart()}
        </div>
      </div>
    </>
  );
};

export default Cart;
