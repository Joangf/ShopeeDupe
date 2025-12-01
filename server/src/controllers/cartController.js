import pool from '../config/database.js';
export const addToCart = async (req, res) => {
  try {
    const { userId, productId, quantity } = req.body;
    const [row] = await pool.query('CALL sp_AddToCart(?, ?, ?)', [userId, productId, quantity]);
    res.status(200).json({ message: 'Product added to cart' });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
}

export const updateCartItem = async (req, res) => {
  try {
    const { userId, productId, quantity } = req.body;
    const [row] = await pool.query('CALL sp_UpdateCartItem(?, ?, ?)', [userId, productId, quantity]);
    res.status(200).json({ message: 'Cart item updated' });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
}

export const removeFromCart = async (req, res) => {
  try {
    const { userId, productId } = req.body;
    const [row] = await pool.query('CALL sp_RemoveFromCart(?, ?)', [userId, productId]);
    res.status(200).json({ message: 'Product removed from cart' });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
}