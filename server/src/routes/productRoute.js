import express from "express";
import {
  addNewProduct,
  getProducts,
  getProductById,
  getReviewsByProductId,
} from "../controllers/productController.js";
const productRoute = express.Router();

productRoute.post("/products", addNewProduct);
productRoute.get("/products", getProducts);
productRoute.get("/products/:id", getProductById);
productRoute.get("/products/:id/reviews", getReviewsByProductId);
export default productRoute;
