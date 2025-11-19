import './App.css'
import { Route, BrowserRouter, Routes } from 'react-router-dom'
import Home from './pages/Home'
import Login from './pages/Login'
import Cart from './pages/Cart'
import ProductDetailPage from './pages/ProductDetailPage'
import OrderPage from './pages/OrderPage'
import OrderDetailPage from './pages/OrderDetailPage'
const App = () => {

  return (
    <BrowserRouter>
      <Routes>
        <Route path='/' element={<Home />} />
        <Route path='/login' element={<Login />} />
        <Route path='/cart' element={<Cart />} />
        <Route path='/product/:productId' element={<ProductDetailPage />} />  
        <Route path='/orders' element={<OrderPage />} />
        <Route path='/orders/:orderId' element={<OrderDetailPage />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
