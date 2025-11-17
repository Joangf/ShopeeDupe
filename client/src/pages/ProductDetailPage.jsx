import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import './ProductDetailPage.css';
import Navbar from '../components/Home/Navbar';
const dummyReviews = [
  { id: 1, author: 'Jane D.', rating: 5, title: 'Excellent Shirt!', text: 'Fits perfectly and the cotton is incredibly soft. Highly recommend.', date: 'November 10, 2025' },
  { id: 2, author: 'Mark T.', rating: 4, title: 'Good, but not perfect', text: 'Nice shirt, but it shrank a little after the first wash. Still, good quality for the price.', date: 'November 5, 2025' }
];

const dummyProduct = {
  id: '1',
  name: 'Modern E-Commerce T-Shirt',
  price: 29.99,
  description: 'A perfect t-shirt to build your e-commerce empire in. Made from 100% premium, soft-touch cotton, this shirt offers both comfort and style. Features a minimalist logo and a modern, tapered fit.',
  defaultImage: 'https://via.placeholder.com/600/F5F5F5/333333?text=Main+Image',
  imageGallery: [
    'https://via.placeholder.com/600/F5F5F5/333333?text=Main+Image',
    'https://via.placeholder.com/600/F5F5F5/333333?text=Angle+1',
    'https://via.placeholder.com/600/F5F5F5/333333?text=Angle+2',
    'https://via.placeholder.com/600/F5F5F5/333333?text=Detail',
  ],
  reviews: dummyReviews
};
// --------------------

// Helper to format price
const formatPrice = (price) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(price);
};

// --- NEW: Star Rating Component ---
const StarRating = ({ rating }) => {
  const totalStars = 5;
  return (
    <div className="star-rating">
      {[...Array(totalStars)].map((_, i) => (
        <svg
          key={i}
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill={i < rating ? '#FFD700' : '#E0E0E0'} // Gold for full, gray for empty
          xmlns="http://www.w3.org/2000/svg"
        >
          <path d="M12 17.27L18.18 21L16.54 13.97L22 9.24L14.81 8.63L12 2L9.19 8.63L2 9.24L7.46 13.97L5.82 21L12 17.27Z" />
        </svg>
      ))}
    </div>
  );
};

const ProductDetailPage = () => {
  const { productId } = useParams();
  const navigate = useNavigate();
  const [quantity, setQuantity] = useState(1);
  const [product, setProduct] = useState(dummyProduct);
  const [currentImage, setCurrentImage] = useState(product.defaultImage);

  const handleQuantityChange = (amount) => {
    setQuantity(prev => Math.max(1, prev + amount));
  };

  const handleAddToCart = () => {
    console.log(`Added ${quantity} of ${product.name} to cart.`);
  };

  return (
    <>
      <Navbar />
      <div className="product-page-container">
        <div className="product-content">
          <h1 className="product-page-title">Product Details</h1>
          <div className="product-detail-layout">
            {/* --- Image Column --- */}
            <div className="product-image-section">
              <img src={currentImage} alt={product.name} className="main-product-image" />
              <div className="image-gallery">
                {product.imageGallery.map((imgUrl, index) => (
                  <button
                    key={index}
                    className={`gallery-thumbnail ${imgUrl === currentImage ? 'active' : ''}`}
                    onClick={() => setCurrentImage(imgUrl)}
                  >
                    <img src={imgUrl} alt={`${product.name} thumbnail ${index + 1}`} />
                  </button>
                ))}
              </div>
            </div>

            {/* --- Info Column --- */}
            <div className="product-info-section">
              <h1 className="product-title">{product.name}</h1>
              <span className="product-price">{formatPrice(product.price)}</span>
              <p className="product-description">{product.description}</p>

              <div className="product-actions">
                <div className="quantity-selector">
                  <button onClick={() => handleQuantityChange(-1)} title="Decrease quantity">-</button>
                  <span>{quantity}</span>
                  <button onClick={() => handleQuantityChange(1)} title="Increase quantity">+</button>
                </div>
                <button className="add-to-cart-button primary-btn" onClick={handleAddToCart}>
                  Add to Cart
                </button>
              </div>
            </div>
          </div>

          {/* --- NEW: Feedback Section --- */}
          <div className="product-feedback-section">
            <div className="feedback-header">
              <h2 className="feedback-title">Customer Reviews</h2>
              <button className="secondary-btn">Write a Review</button>
            </div>
            <div className="feedback-list">
              {product.reviews.length > 0 ? (
                product.reviews.map(review => (
                  <div key={review.id} className="review-card">
                    <div className="review-card-header">
                      <StarRating rating={review.rating} />
                      <span className="review-date">{review.date}</span>
                    </div>
                    <h3 className="review-title">{review.title}</h3>
                    <p className="review-author">by {review.author}</p>
                    <p className="review-text">{review.text}</p>
                  </div>
                ))
              ) : (
                <p className="no-reviews-text">Be the first to review this product!</p>
              )}
            </div>
          </div>
          
        </div>
      </div>
    </>
  );
};

export default ProductDetailPage;