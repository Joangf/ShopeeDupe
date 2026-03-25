import express from "express";
import authenticationToken from '../middleware/authUser.js';
import {
  addNewProduct,
  getProducts,
  getProductById,
  getReviewsByProductId,
  searchProductsByKeyword,
  postReviewsByProductId,
  getProductBySellerId
} from "../controllers/productController.js";
const productRoute = express.Router();

productRoute.get("/products", getProducts);
productRoute.get("/products/:id", getProductById);
productRoute.get("/products/seller/:sellerId", getProductBySellerId);
productRoute.get("/products/:id/reviews", getReviewsByProductId);
productRoute.get("/search/products", searchProductsByKeyword);
productRoute.post("/products", authenticationToken, addNewProduct);
productRoute.post("/products/:id/reviews", authenticationToken, postReviewsByProductId);
export default productRoute;
