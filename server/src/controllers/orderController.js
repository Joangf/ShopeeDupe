import pool from "../config/database.js";

export const createOrder = async (req, res) => {
  try {
    const {
      userId,
      shipmentAddress
    } = req.body;
    if (!userId || !shipmentAddress) {
      return res.status(400).json({ error: "Missing required fields" });
    }
    const [row] = await pool.query("CALL sp_CreateOrder(?, ?)", [userId, shipmentAddress]);
    return res.status(200).json({
      message: "Order created successfully"
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
}