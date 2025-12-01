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
    res.status(500).json({ error: "Internal server errors" });
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

