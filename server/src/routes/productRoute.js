import express from "express";
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

productRoute.post("/products", addNewProduct);
productRoute.get("/products", getProducts);
productRoute.get("/products/:id", getProductById);
productRoute.get("/products/seller/:sellerId", getProductBySellerId);
productRoute.get("/products/:id/reviews", getReviewsByProductId);
productRoute.post("/products/:id/reviews", postReviewsByProductId);
productRoute.get("/search/products", searchProductsByKeyword);
export default productRoute;
