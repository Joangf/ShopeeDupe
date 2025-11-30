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