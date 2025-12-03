import ProductGrid from "../components/Home/ProductGrid";
import Navbar from "../components/Home/Navbar";
import InfiniteScroll from "react-infinite-scroll-component";
const API_URL = import.meta.env.VITE_BACKEND_URL;
import { useEffect, useState } from "react";
const Home = ({ setIsLoggedIn, isLoggedIn }) => {
  const [products, setProducts] = useState([]);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);

  useEffect(() => {
    let isMounted = true;
    const fetchProducts = async (pageNumber) => {
      try {
        const response = await fetch(`${API_URL}/products?page=${pageNumber}`);
        if (response.ok && isMounted) {
          const data = await response.json();
          const products = data.products;
          if (products.length === 0) {
            setHasMore(false);
          } else {
            setProducts((prevProducts) => [...prevProducts, ...products]);
          }
        }
      } catch (error) {
        console.error("Failed to fetch products:", error);
      }
    };
    fetchProducts(page);
    return () => {
      isMounted = false;
    };
  }, [page]);
  return (
    <>
      <Navbar setIsLoggedIn={setIsLoggedIn} isLoggedIn={isLoggedIn} />
      { products.length > 0 && (<ProductGrid products={products} />)}
      <InfiniteScroll
        dataLength={products.length}
        next={() => setPage((prevPage) => prevPage + 1)}
        hasMore={hasMore}
        loader={ <h4 style={{ textAlign: "center" }}>Loading...</h4>}
      />
    </>
  );
};
export default Home;
