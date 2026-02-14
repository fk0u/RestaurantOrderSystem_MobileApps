# Backend API Documentation

The `RestaurantOrderSystem_MobileApps` backend is built with **Node.js** and **Express**, using **MySQL** as the database.

## Base URL
*   **Local Development**: `http://localhost:3000` (or your machine's IP address, e.g., `http://10.0.2.2:3000` for Android Emulator).

## Headers
*   `Content-Type: application/json`
*   `Authorization`: `Bearer <token>` (for protected routes - *Note: Basic token implementation for prototype*)

---

## 🔐 Authentication

### Login
*   **Endpoint**: `POST /api/auth/login`
*   **Body**:
    ```json
    {
      "email": "user@resto.com",
      "password": "password"
    }
    ```
*   **Response**: Returns user object and token.

### Register
*   **Endpoint**: `POST /api/auth/register`
*   **Body**:
    ```json
    {
      "name": "New User",
      "email": "new@resto.com",
      "password": "password"
    }
    ```

---

## 🍔 Products & Menu

### Get All Products
*   **Endpoint**: `GET /api/products`
*   **Response**: List of products with category names.

### Create Product
*   **Endpoint**: `POST /api/products`
*   **Body**:
    ```json
    {
      "name": "Nasi Goreng",
      "price": 25000,
      "imageUrl": "http://...",
      "categoryId": 1,
      "description": "Tasty fried rice",
      "stock": 100,
      "isAvailable": true
    }
    ```

### Update Product
*   **Endpoint**: `PUT /api/products/:id`

### Delete Product
*   **Endpoint**: `DELETE /api/products/:id`

---

## 📂 Categories

### Get Categories
*   **Endpoint**: `GET /api/categories`

### Create Category
*   **Endpoint**: `POST /api/categories`
*   **Body**: `{ "name": "Food", "description": "Main dishes" }`

### Update Category
*   **Endpoint**: `PUT /api/categories/:id`

### Delete Category
*   **Endpoint**: `DELETE /api/categories/:id`

---

## 🪑 Tables

### Get All Tables
*   **Endpoint**: `GET /api/tables`

### Update Table Status
*   **Endpoint**: `PUT /api/tables/:id`
*   **Body**: `{ "status": "occupied" }`
    *   *Status options*: `available`, `occupied`, `reserved`

---

## 🧾 Orders

### Get All Orders
*   **Endpoint**: `GET /api/orders`
*   **Response**: List of orders, including their items and modifiers.

### Get Next Queue Number
*   **Endpoint**: `GET /api/orders/queue`

### Create Order
*   **Endpoint**: `POST /api/orders`
*   **Body**:
    ```json
    {
      "id": "order-uuid",
      "userId": 1,
      "userName": "Customer Name",
      "totalPrice": 50000,
      "status": "pending",
      "orderType": "dine_in",
      "queueNumber": 12,
      "tableId": "table_app_id",
      "items": [
        {
          "productId": 1,
          "quantity": 2,
          "note": "Spicy",
          "modifiers": []
        }
      ],
      "paymentMethod": "cash"
    }
    ```
*   **Logic**: Checks stock availability before creating order. Deducts stock upon success.

### Update Order Status
*   **Endpoint**: `PATCH /api/orders/:id/status`
*   **Body**: `{ "status": "cooking" }`

### Process Payment
*   **Endpoint**: `POST /api/orders/:id/payment`
*   **Body**: `{ "method": "cash", "amount": 50000 }`

---

## 📊 Dashboard

### Get Sales Stats
*   **Endpoint**: `GET /api/sales/stats`
*   **Response**:
    ```json
    {
      "count": 150,
      "revenue": 5000000,
      "active_orders": 5
    }
    ```
