import { useNavigate } from 'react-router-dom';
import './ProductGrid.css'; // Renamed CSS import

const ProductGrid = ({ products, displaySecTitle = true, backgroundColor = '#FFFFFF', pad1 = '60px', pad2 = '40px' }) => {

  // Helper to format price (e.g., 29.99 -> $29.99)
  const navigate = useNavigate();
  const formatPrice = (price) => {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND',
    }).format(price);
  };
  return (
    <section className="product-grid" style={{
      "--color": backgroundColor,
      "--pad1": pad1,
      "--pad2": pad2,
    }}>
      <div className="product-grid-content">
        {displaySecTitle && <h2 className="grid-section-title">Shop The Collection</h2>}
        <div className="product-grid-container">
          {products.map((product) => (
            <div
              key={product.ProductID}
              className="product-grid-item"
              title={`${product.Name} - ${formatPrice(product.Price)}`} // Updated title
              onClick={() => navigate(`/product/${product.ProductID}`)}
            >
              <img src={product.ImageURL} alt={product.Name} className="product-image" />
              <div className="product-info">
                <h3 className="product-name">{product.Name}</h3>
                <p className="product-price">{formatPrice(product.Price)}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default ProductGrid;