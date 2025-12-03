import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './Navbar.css';
const API_URL = import.meta.env.VITE_BACKEND_URL;

const LogoIcon = () => (
  <svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M20 2.5L37.5 12.5V32.5L20 22.5L2.5 32.5V12.5L20 2.5Z" stroke="#222222" strokeWidth="2" strokeLinejoin="round"/>
    <path d="M2.5 12.5L20 22.5L37.5 12.5" stroke="#222222" strokeWidth="2" strokeLinejoin="round"/>
    <path d="M20 37.5V22.5" stroke="#222222" strokeWidth="2" strokeLinejoin="round"/>
  </svg>
);

const CartIcon = () => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M7 18C5.9 18 5.01 18.9 5.01 20C5.01 21.1 5.9 22 7 22C8.1 22 9 21.1 9 20C9 18.9 8.1 18 7 18ZM17 18C15.9 18 15.01 18.9 15.01 20C15.01 21.1 15.9 22 17 22C18.1 22 19 21.1 19 20C19 18.9 18.1 18 17 18ZM1 2H5.27L8.1 10.16L6.75 12.75C6.58 13.07 6.5 13.43 6.5 13.8C6.5 14.9 7.4 15.8 8.5 15.8H18.5V13.8H8.84C8.71 13.8 8.6 13.69 8.6 13.56L8.63 13.48L9.6 11.8H16.86C17.5 11.8 18.06 11.43 18.32 10.84L21.9 4.63C21.96 4.52 22 4.39 22 4.25C22 3.81 21.69 3.5 21.25 3.5H5.21L4.27 1.5H1V2Z" fill="currentColor"/>
  </svg>
);
const OrderIcon = () => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M18 17H6C5.45 17 5 17.45 5 18C5 18.55 5.45 19 6 19H18C18.55 19 19 18.55 19 18C19 17.45 18.55 17 18 17ZM19 8H5C4.45 8 4 8.45 4 9V11C4 11.55 4.45 12 5 12H19C19.55 12 20 11.55 20 11V9C20 8.45 19.55 8 19 8ZM18 13H6C5.45 13 5 13.45 5 14C5 14.55 5.45 15 6 15H18C18.55 15 19 14.55 19 14C19 13.45 18.55 13 18 13ZM20 3H4C2.9 3 2 3.9 2 5V19C2 20.1 2.9 21 4 21H20C21.1 21 22 20.1 22 19V5C22 3.9 21.1 3 20 3ZM20 19H4V5H20V19Z" fill="currentColor"/>
  </svg>
);

const Navbar = ({isLoggedIn, setIsLoggedIn, activeCategories}) => {
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [searchValue, setSearchValue] = useState('');
  const [isSearchDropdownOpen, setIsSearchDropdownOpen] = useState(false);
  const [searchResult, setSearchResult] = useState([]);
  const dropdownRef = useRef(null);
  const profileRef = useRef(null);  
  const searchDropdownRef = useRef(null);
  const searchInputRef = useRef(null);
  const navigate = useNavigate();

  // Close dropdowns when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target) &&
          profileRef.current && !profileRef.current.contains(event.target)) {
        setIsDropdownOpen(false);
      }

      if (searchDropdownRef.current && !searchDropdownRef.current.contains(event.target) &&
          searchInputRef.current && !searchInputRef.current.contains(event.target)) {
        setIsSearchDropdownOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const toggleDropdown = () => {
    setIsDropdownOpen(!isDropdownOpen);
  };

  const handleLogin = () => {
    setIsDropdownOpen(false);
    navigate("/login");
  };

  const handleProfile = () => {
    setIsDropdownOpen(false);
    navigate("/profile");
  };

  const handleSearchChange = async (e) => {
    const value = e.target.value;
    setSearchValue(value);
    setIsSearchDropdownOpen(value.length > 0);
    if (value.length === 0) {
      setSearchResult([]);
      return;
    }
    try {
      const response = await fetch(`${API_URL}/search/products?keyword=${value}`);
      const data = await response.json();
      if(!response.ok){
        console.log("Searching failed");
        return;
      }
      setSearchResult(data.products);
    }
    catch(error){
      console.log(error);
    }
  }

  const handleSearchFocus = () => {
    if (searchValue.length > 0) {
      setIsSearchDropdownOpen(true);
    }
  };

  const handleBookSelect = (product) => {
    setSearchValue(product.Name);
    setIsSearchDropdownOpen(false);
    navigate(`/product/${product.ProductID}`);
  };

  const handleLogout = async () => {
    try{
      const id = localStorage.getItem('idUser');
      if (id) {
        console.log("Logged out successfully");
        setIsDropdownOpen(false);
        setIsLoggedIn(false);
        localStorage.setItem('isLoggedIn', 'false');
        localStorage.removeItem('idUser');
        localStorage.removeItem('nameUser');
        navigate("/");
      }
    } catch (error) {
      console.error("Logout failed:", error);
    }
  };

  return (
    // Changed class to 'navbar-light-theme'
    <nav className="navbar navbar-light-theme"> 
      <div className="navbar-content">
        {/* Logo Section */}
        <button
          type="button"
          className="logo-section logo-navigation-button"
          onClick={() => navigate('/')}
        >
          <LogoIcon />
          <div className="logo-text">
            {/* Kept "BOOKS" but you can change this to "STORE" etc. */}
            <span className="logo-keazon">Dupe</span>
            <span className="logo-books">STORE</span> 
          </div>
        </button>

        {/* Search Section */}
        <div className="search-section">
          <div className="search-container">
            <svg className="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M15.5 14H14.71L14.43 13.73C15.41 12.59 16 11.11 16 9.5C16 5.91 13.09 3 9.5 3C5.91 3 3 5.91 3 9.5C3 13.09 5.91 16 9.5 16C11.11 16 12.59 15.41 13.73 14.43L14 14.71V15.5L19 20.49L20.49 19L15.5 14ZM9.5 14C7.01 14 5 11.99 5 9.5C5 7.01 7.01 5 9.5 5C11.99 5 14 7.01 14 9.5C14 11.99 11.99 14 9.5 14Z" fill="#555"/>
            </svg>
            <input
              ref={searchInputRef}
              type="text"
              className="search-input"
              placeholder="Search for products..." // Updated placeholder
              value={searchValue}
              onChange={handleSearchChange}
              onFocus={handleSearchFocus}
            />
          </div>

          {isSearchDropdownOpen && (
            <div ref={searchDropdownRef} className="search-dropdown">
              {searchResult.map((product) => (
                <div
                  key={product.ProductID}
                  className="search-book-item" // Renamed to .search-product-item in CSS
                  onClick={() => handleBookSelect(product)}
                >
                  <div className="search-book-title">{product.Name}</div>
                  <div className="search-book-author">by {product.BrandName}</div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Actions & Profile Section */}
        <div className="actions-section">
          
          {/* Replaced Library and Notifications with Cart */}
          <button className="action-button" title="Shopping Cart" onClick={() => navigate("/cart")}>
            <CartIcon />
          </button>
          <button className="action-button" title="My Orders" onClick={() => navigate("/orders")}>
            <OrderIcon />
          </button>
          {isLoggedIn  
            ?(
              <div className="profile-wrapper">
                <div
                  ref={profileRef}
                  className="profile-section"
                  onClick={toggleDropdown}
                  title="My Account"
                >
                  <img
                    src="https://api.builder.io/api/v1/image/assets/TEMP/21e8c4ad58b36ddd2a9af3f8fa0325468a156350?width=100"
                    alt="Profile"
                    className="profile-image"
                  />
                </div>

                {isDropdownOpen && (
                  <div ref={dropdownRef} className="profile-dropdown">
                    <button className="dropdown-item" onClick={handleProfile}>
                      Profile
                    </button>
                    <button className="dropdown-item logout-item" onClick={handleLogout}>
                      Logout
                    </button>
                  </div>
                )}
              </div>
            )
            :(
              <button className="login-button secondary-btn" onClick={handleLogin}>
                Login
              </button>
            )
          }
          
        </div>
      </div>
    </nav>
  );
};

export default Navbar;