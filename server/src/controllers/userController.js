import pool from '../config/database.js';
export const getUsers = async (req, res) => {
    const sql = 'SELECT * FROM User';
    const [rows] = await pool.query(sql);
    res.json(rows);
}
export const postUser = async (req, res) => {
    const { name, email } = req.body;
    const sql = 'INSERT INTO User (FullName, Email) VALUES (?, ?);';
    const [result] = await pool.query(sql, [name, email]);
    res.json({ message: 'User created', userId: result.insertId });
}