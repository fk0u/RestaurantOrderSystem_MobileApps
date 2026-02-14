# Backend API Documentation

The `RestaurantOrderSystem_MobileApps` is designed to interact with a RESTful backend API. Currently, the application uses a `MockService` for development and testing, but the architecture is set up to communicate with a Laravel-based backend.

## Base URL
- **Development (Android Emulator)**: `http://10.0.2.2:8000/api`
- **Development (Web/iOS)**: `http://127.0.0.1:8000/api`
- **Production**: `https://api.your-production-domain.com/api`

## Authentication

### Login
- **Endpoint**: `POST /auth/login`
- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "secret_password"
  }
  ```
- **Response (Success - 200 OK)**:
  ```json
  {
    "token": "eyJhbGciOiJIUzI1Ni...",
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "user@example.com",
      "role": "staff" // or 'admin', 'customer'
    }
  }
  ```

### Logout
- **Endpoint**: `POST /auth/logout`
- **Headers**: `Authorization: Bearer <token>`

## Tables

### Get All Tables
- **Endpoint**: `GET /tables`
- **Response**: Array of table objects.

### Update Table Status
- **Endpoint**: `PUT /tables/{id}`
- **Request Body**:
  ```json
  {
    "status": "occupied" // 'available', 'reserved', 'occupied'
  }
  ```

## Menu (Products)

### Get Products
- **Endpoint**: `GET /products`
- **Query Parameters**: `category` (optional)
- **Response**: Array of product objects.

## Orders

### Create Order
- **Endpoint**: `POST /orders`
- **Request Body**:
  ```json
  {
    "table_id": "table_1",
    "items": [
      {
        "product_id": "p1",
        "quantity": 2,
        "note": "No spicy"
      }
    ]
  }
  ```

### Get Orders
- **Endpoint**: `GET /orders`
- **Query Parameters**: `status` (optional), `date` (optional)

### Update Order Status
- **Endpoint**: `PATCH /orders/{id}/status`
- **Request Body**:
  ```json
  {
    "status": "Sedang Dimasak" // 'Sedang Diproses', 'Siap Saji', 'Selesai'
  }
  ```

### Process Payment
- **Endpoint**: `POST /orders/{id}/payment`
- **Request Body**:
  ```json
  {
    "method": "qris", // 'cash', 'qris'
    "amount": 50000
  }
  ```

## WebSocket (Real-time Updates)
The app is configured to use Pusher Channels for real-time updates (e.g., new orders in kitchen).
- **Cluster**: `mt1` (configurable in `AppConfig`)
- **Channel**: `orders`
- **Events**:
  - `order.created`: New order placed.
  - `order.updated`: Order status changed.
