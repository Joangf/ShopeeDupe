# ShopeeDupe

A full-stack e-commerce practice project inspired by Shopee, built with React + Vite, Express.js, and MySQL.

## Overview

ShopeeDupe includes:

- Customer authentication (register, login, OTP flow, password reset)
- Product browsing with infinite scrolling and keyword search
- Product detail and review features
- Shopping cart management
- Order creation, payment status update, and order history/details
- User profile and seller center pages

The project is split into:

- `client/`: React frontend
- `server/`: Express API server
- `initsql/`: MySQL schema, seed data, procedures/functions
- `docker-compose.yml`: One-command multi-service startup

## Tech Stack

- Frontend: React 19, Vite, React Router
- Backend: Node.js, Express 5, JWT, cookie-parser, nodemailer
- Database: MySQL 8
- Containerization: Docker + Docker Compose

## Project Structure

```text
ShopeeDupe/
|-- client/           # React app (served by Nginx in Docker)
|-- server/           # Express API
|-- initsql/          # DB schema + seed + SQL functions/procedures
|-- test/             # SQL tests
`-- docker-compose.yml
```

## Prerequisites

Choose one of the following workflows:

- Docker workflow:
	- Docker Desktop
	- Docker Compose
- Local workflow:
	- Node.js 20+
	- MySQL 8+
	- npm

## Quick Start (Docker Recommended)

From the project root:

```bash
docker compose up --build
```

Services:

- Frontend: http://localhost:5173
- Backend API: http://localhost:3000
- MySQL: localhost:3306

Docker Compose automatically mounts `initsql/` into MySQL startup scripts.

To stop:

```bash
docker compose down
```

To also remove DB volume:

```bash
docker compose down -v
```

## Local Development Setup

### 1. Install dependencies

```bash
# frontend
cd client
npm install

# backend
cd ../server
npm install
```

### 2. Create environment files

Frontend (`client/.env`):

```env
VITE_BACKEND_URL=http://localhost:3000/api
```

Backend (`server/.env`):

```env
SERVER_PORT=3000

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root
DB_NAME=shopeedupe

JWT_SECRET=shopeedupe

EMAIL_USER=your_email@example.com
EMAIL_PASS=your_email_password_or_app_password
```

### 3. Prepare database

Create a MySQL database named `shopeedupe`, then run SQL files in `initsql/` in order.

Suggested order:

1. `01-Table.sql`
2. `02-InitData.sql`
3. All `03-*.sql` files
4. `04-Function.sql`

### 4. Start apps

Backend:

```bash
cd server
npm run dev
```

Frontend:

```bash
cd client
npm run dev
```

Frontend dev URL is typically shown by Vite (default: http://localhost:5173).

## Available Scripts

### Client

- `npm run dev`: start Vite dev server
- `npm run build`: production build
- `npm run preview`: preview production build
- `npm run lint`: run ESLint

### Server

- `npm run dev`: start API with nodemon
- `npm start`: start API with node

## API Overview

Base URL:

- Local: `http://localhost:3000/api`

Main route groups:

- Auth/User
	- `POST /auth/register/customer`
	- `POST /auth/register/otp`
	- `POST /auth/login/customer`
	- `POST /auth/login/seller`
	- `POST /auth/forgot-password`
	- `POST /auth/reset-password`
	- `GET /user/:id`
	- `PUT /user/:id`
	- `GET /user/role/:id`

- Products
	- `GET /products`
	- `GET /products/:id`
	- `GET /products/seller/:sellerId`
	- `GET /products/:id/reviews`
	- `GET /search/products`
	- `POST /products` (auth required)
	- `POST /products/:id/reviews` (auth required)

- Cart (auth required)
	- `POST /cart/add`
	- `PUT /cart/update`
	- `DELETE /cart/remove`
	- `GET /cart/:userId`

- Orders (auth required)
	- `POST /order/create`
	- `GET /order/user/:userId`
	- `GET /order/details/:orderId`
	- `PUT /order/payment`

Authentication is cookie-based using JWT (`token` cookie).

## Notes

- The frontend expects `VITE_BACKEND_URL` to include `/api`.
- The backend uses environment fallbacks if some variables are not provided.
- Email features (OTP/reset) require valid SMTP credentials.

## License

This project is for educational/practice purposes.
