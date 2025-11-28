import ProductGrid from "../components/Home/ProductGrid";
import Navbar from "../components/Home/Navbar";
const Home = ({setIsLoggedIn, isLoggedIn}) => {
  return (
    <>
      <Navbar setIsLoggedIn={setIsLoggedIn} isLoggedIn={isLoggedIn} />
      <ProductGrid />
    </>
)};
export default Home;