import './App.css'
import { Route, BrowserRouter, Routes } from 'react-router-dom'
import { useState } from 'react'
import Home from './pages/Home'
import Login from './pages/Login'
import Cart from './pages/Cart'
import ProductDetailPage from './pages/ProductDetailPage'
import OrderPage from './pages/OrderPage'
import OrderDetailPage from './pages/OrderDetailPage'
import UserProfilePage from './pages/UserProfilePage'
const App = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(localStorage.getItem('isLoggedIn') === 'true');

  return (
    <BrowserRouter>
      <Routes>
        <Route path='/' element={<Home setIsLoggedIn={setIsLoggedIn} isLoggedIn={isLoggedIn} />} />
        <Route path='/profile' element={<UserProfilePage setIsLoggedIn={setIsLoggedIn} isLoggedIn={isLoggedIn} />} />
        <Route path='/login' element={<Login setIsLoggedIn={setIsLoggedIn} />} />
        <Route path='/cart' element={<Cart setIsLoggedIn={setIsLoggedIn} isLoggedIn={isLoggedIn} />} />
        <Route path='/product/:productId' element={<ProductDetailPage setIsLoggedIn={setIsLoggedIn} isLoggedIn={isLoggedIn} />} />  
        <Route path='/orders' element={<OrderPage setIsLoggedIn={setIsLoggedIn} isLoggedIn={isLoggedIn} />} />
        <Route path='/orders/:orderId' element={<OrderDetailPage setIsLoggedIn={setIsLoggedIn} isLoggedIn={isLoggedIn} />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
