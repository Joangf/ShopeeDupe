import e from "express";
import pool from "../config/database.js";

export const addNewProduct = async (req, res) => {
  try {
    const{
      sellerId,
      name,
      barcode,
      brandname,
      description,
      price,
      stockQuantity,
      imageURL
    } = req.body;
    if(!sellerId || !name || !price || !stockQuantity){
      return res.status(400).json({ error: "Missing required fields" });
    }

    const [row] = await pool.query("CALL sp_AddNewProduct(?, ?, ?, ?, ?, ?, ?, ?)",
      [
        sellerId,
        name,
        barcode,
        brandname,
        description,
        price,
        stockQuantity,
        imageURL
      ]
    );
    if (!row[0][0]){
        return res.status(401).json({ error: "Have errors in query" });
    }
    return res.status(200).json({
      message: "Successful",
      data: row[0][0]
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(400).json({ error: error.message });
  }
};

export const getProducts = async (req, res) => {
  try {
  const page = Number(req.query.page) || 1;
  const pageSize = 30;  
  const offset = (page - 1) * pageSize;
  const [count] = await pool.query("SELECT COUNT(*) AS total FROM Product WHERE StockQuantity > 0");
  const totalProducts = count[0].total;
  const [rows] = await pool.query(
    "SELECT * FROM Product WHERE StockQuantity > 0 ORDER BY ProductID LIMIT ? OFFSET ?",
    [pageSize, offset]
  );
    return res.status(200).json({
      message: "Successful",
      products: rows,
      pagination: {
        currentPage: page,
        pageSize: pageSize,
        totalProducts: totalProducts,
        totalPages: Math.ceil(totalProducts / pageSize)
      }
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};

export const getProductById = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.query(
      "SELECT * FROM Product WHERE ProductID = ?",
      [id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: "Product not found" });
    }
    return res.status(200).json({
      message: "Successful",
      product: rows[0]
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};

export const getReviewsByProductId = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.query(
      "SELECT * FROM Review WHERE ProductID = ?",
      [id]
    );
    return res.status(200).json({
      message: "Successful",
      reviews: rows
    });
  }
  catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};


export const searchProductsByKeyword = async (req, res) => {
  try {
    const { keyword } = req.query;
    if (!keyword) {
      return res.status(400).json({ error: "Keyword query parameter is required" });
    }
    const searchTerm = `%${keyword}%`;
    const [rows] = await pool.query(
      "SELECT * FROM Product WHERE Name LIKE ? OR Description LIKE ?",
      [searchTerm, searchTerm]
    );
    return res.status(200).json({
      message: "Successful",
      products: rows
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};

export const postReviewsByProductId = async (req, res) => {
  try {
    const { id } = req.params;
    const {customerName, title, content, customerId} = req.body;
    if (!customerName || !title || !content || !customerId) {
      return res.status(400).json({ error: "Missing required fields" });
    }
    const [result] = await pool.query('CALL CreateReview(?, ?, ?, ?, ?)',
      [
        id,
        customerName,
        title,
        content,
        customerId,
      ]
    );
    return res.status(200).json({
      message: "Review created successfully",
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};

export const getProductBySellerId = async (req, res) => {
  try {
    const { sellerId } = req.params;
    const [rows] = await pool.query(
      "SELECT * FROM Product WHERE SellerID = ?",
      [sellerId]
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: "No products found for this seller" });
    }
    return res.status(200).json({
      message: "Successful",
      products: rows
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};