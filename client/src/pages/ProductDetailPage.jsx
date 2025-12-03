import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import './ProductDetailPage.css';
import Navbar from '../components/Home/Navbar';
import TickingFail from '../components/Notifications/TickingFail';
import TickingSuccess from '../components/Notifications/TickingSuccess';
const API_URL = import.meta.env.VITE_BACKEND_URL;

// Helper to format price
const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(price);
};

const ProductDetailPage = ({ isLoggedIn, setIsLoggedIn }) => {
  const { productId } = useParams();
  const navigate = useNavigate();
  
  // Product Data States
  const [quantity, setQuantity] = useState(1);
  const [product, setProduct] = useState({});
  const [reviews, setReviews] = useState([]);
  
  // Review Form States
  const [loginToReview, setLoginToReview] = useState(false);
  const [reviewSuccess, setReviewSuccess] = useState(false);
  const [reviewTitle, setReviewTitle] = useState('');
  const [reviewContent, setReviewContent] = useState('');

  const handleQuantityChange = (amount) => {
    setQuantity(prev => Math.max(1, prev + amount));
  };

  const handleAddToCart = async () => {
    if (!isLoggedIn) {
      setLoginToReview(true);
      setTimeout(() => navigate('/login'), 2000);
      return;
    }
    try {
      const response = await fetch(`${API_URL}/cart/add`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          userId: localStorage.getItem('idUser'),
          productId: product.ProductID,
          quantity: quantity,
        }),
      });
      if (response.ok) {
        setReviewSuccess(true);
        setTimeout(() => setReviewSuccess(false), 2000);
      }
    } catch (error) {
      console.error('Error adding to cart:', error);
    }
  };

  const handleReviewSubmit = async (e) => {
    e.preventDefault();

    if (!isLoggedIn) {
      setLoginToReview(true);
      setTimeout(() => navigate('/login'), 2000);
      return;
    }


    const reviewData = {
      id: productId,
      customerName: localStorage.getItem('nameUser'),
      title: reviewTitle,
      content: reviewContent,
      customerId: localStorage.getItem('idUser'),
    };
    try {
      const response = await fetch(`${API_URL}/products/${productId}/reviews`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(reviewData),
      });
      if (response.ok) {
        window.location.reload();
      } else {
        console.error('Failed to submit review');
      }
    } catch (error) {
      console.error('Error submitting review:', error);
    }

    setReviewTitle('');
    setReviewContent('');
  };

  useEffect(() => {
    const fetchProductDetails = async () => {
      try {
        const response = await fetch(`${API_URL}/products/${productId}`);
        if (response.ok) {
          const data = await response.json();
          setProduct(data.product);
        } else {
          console.error('Failed to fetch product details');
        }
      } catch (error) {
        console.error('Error fetching product details:', error);
      }
    };

    const fetchProductReviews = async () => {
      try {
        const response = await fetch(`${API_URL}/products/${productId}/reviews`);
        if (response.ok) {
          const data = await response.json();
          setReviews(data.reviews);
        }
      } catch (error) {
        console.error('Error fetching product reviews:', error);
      }
    };

    fetchProductDetails();
    fetchProductReviews();
  }, [productId]);

  return (
    <>
      {loginToReview && !isLoggedIn && <TickingFail message="Please log in to submit." isVisible={true} />}
      {reviewSuccess && <TickingSuccess message="Added to cart successfully!" isVisible={true} />}
      <Navbar isLoggedIn={isLoggedIn} setIsLoggedIn={setIsLoggedIn} />
      <div className="product-page-container">
        <div className="product-content">
          <h1 className="product-page-title">Product Details</h1>
          <div className="product-detail-layout">
            {/* --- Image Column --- */}
            <div className="product-image-section">
              <img src={product.ImageURL} alt={product.Name} className="main-product-image" />
            </div>

            {/* --- Info Column --- */}
            <div className="product-info-section">
              <h1 className="product-title">{product.Name}</h1>
              <span className="product-price">{product.Price ? formatPrice(product.Price) : ''}</span>
              <p className="product-description">{product.Description}</p>

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

          {/* --- Feedback Section --- */}
          <div className="product-feedback-section">
            <div className="feedback-header">
              <h2 className="feedback-title">Customer Reviews</h2>
              {/* REMOVED: "Write a Review" button */}
            </div>

            <div className="feedback-list">
              {reviews.length > 0 ? (
                reviews.map(review => (
                  <div key={review.ReviewID} className="review-card">
                    <div className="review-card-header">
                      <span className="review-date">{new Date(review.CreatedAt).toLocaleDateString()}</span>
                    </div>
                    <h3 className="review-title">{review.Title}</h3>
                    <p className="review-author">by {review.CustomerName}</p>
                    <p className="review-text">{review.Content}</p>
                  </div>
                ))
              ) : (
                <p className="no-reviews-text">Be the first to review this product!</p>
              )}
            </div>

            {/* --- NEW: Inline Review Form --- */}
            <form className="product-review-form" onSubmit={handleReviewSubmit}>
              <h3>Write a Review</h3>
              
              <div className="review-form-group">
                <label htmlFor="reviewTitle">Title</label>
                <input 
                  type="text" 
                  id="reviewTitle" 
                  placeholder="Summarize your experience" 
                  value={reviewTitle}
                  onChange={(e) => setReviewTitle(e.target.value)}
                  required 
                />
              </div>

              <div className="review-form-group">
                <label htmlFor="reviewContent">Review</label>
                <textarea 
                  id="reviewContent" 
                  placeholder="How was the quality, fit, etc?" 
                  value={reviewContent}
                  onChange={(e) => setReviewContent(e.target.value)}
                  required
                />
              </div>

              <button type="submit" className="primary-btn submit-review-btn">
                Submit Review
              </button>
            </form>

          </div>
          
        </div>
      </div>
    </>
  );
};

export default ProductDetailPage;