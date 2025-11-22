import { useNavigate } from 'react-router-dom';
import './ProductGrid.css'; // Renamed CSS import

const ProductGrid = ({ products, displaySecTitle = true, backgroundColor = '#FFFFFF', pad1 = '60px', pad2 = '40px' }) => {

  // Helper to format price (e.g., 29.99 -> $29.99)
  const navigate = useNavigate();
  const formatPrice = (price) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(price);
  };
  if (!products || products.length === 0) {
    products = [
      { id: 1, name: 'Sample Product 1', price: 29.99, imageUrl: 'https://via.placeholder.com/150' },
      { id: 2, name: 'Sample Product 2', price: 49.99, imageUrl: 'https://via.placeholder.com/150' },
      { id: 3, name: 'Sample Product 3', price: 19.99, imageUrl: 'https://via.placeholder.com/150' },
      { id: 4, name: 'Sample Product 4', price: 99.99, imageUrl: 'https://via.placeholder.com/150' },
    ];
  }
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
              key={product.id}
              className="product-grid-item"
              title={`${product.name} - ${formatPrice(product.price)}`} // Updated title
              onClick={() => navigate(`/product/${product.id}`)}
            >
              <img src={product.imageUrl} alt={product.name} className="product-image" />
              <div className="product-info">
                <h3 className="product-name">{product.name}</h3>
                <p className="product-price">{formatPrice(product.price)}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default ProductGrid;