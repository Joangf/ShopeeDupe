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
      message: "Order created successfully",
      order: row[0][0]
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
}
export const getOrdersByUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const [rows] = await pool.query("SELECT * FROM `Order` WHERE CustomerID = ?", [userId]);
    res.status(200).json(rows);
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
}

export const getOrderDetails = async (req, res) => {
  try {
    const { orderId } = req.params;
    const [rows] = await pool.query("SELECT o.OrderDate, o.TotalAmount, o.Status, o.PaymentMethod, o.ShippingAddress, pi.ProductID, pi.Quantity\
                                    FROM `Order` o JOIN Package p\
                                    ON o.OrderID = p.OrderID JOIN PackageItem pi\
                                    ON p.PackageID = pi.PackageID WHERE o.OrderID = ?", [orderId]);
    const [productRows] = await pool.query("SELECT * FROM Product WHERE ProductID IN (?)", [rows.map(r => r.ProductID)]);
    res.status(200).json({
      orderDate: rows[0]?.OrderDate,
      totalAmount: rows[0]?.TotalAmount,
      status: rows[0]?.Status,
      shippingAddress: rows[0]?.ShippingAddress,
      paymentMethod: rows[0]?.PaymentMethod,
      products: productRows.map(product => ({
        ...product,
        Quantity: rows.find(r => r.ProductID === product.ProductID)?.Quantity || 0
      }))
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
}

export const updateOrderPayment = async (req, res) => {
  try {
    const { userId ,orderId, paymentMethod } = req.body;
    const [row] = await pool.query("CALL sp_ProcessPayment(?, ?, ?)", [userId, orderId, paymentMethod]);
    res.status(200).json({ 
      message: "Payment processed successfully" ,
      payment: row[0][0]
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(400).json({ error: error});
  }
}