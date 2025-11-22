import pool from '../config/database.js';
export const getUsers = async (req, res) => {
    const sql = 'SELECT * FROM User';
    const [rows] = await pool.query(sql);
    res.json(rows);
}
export const postUser = async (req, res) => {
    const { username, email } = req.body;
    const sql = 'CALL sp_AddNewUser (?, ?)';
}