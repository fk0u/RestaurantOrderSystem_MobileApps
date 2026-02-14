# Restaurant Order System (Mobile App)

A comprehensive mobile application for restaurant management, built with Flutter. This app covers the entire flow from customer ordering to kitchen processing and admin monitoring.

## 📱 Features

-   **Authentication**: Login for different roles (Customer, Staff, Admin).
-   **Table Management**: View table layout and status (Available, Occupied, Reserved).
-   **Menu & Ordering**: Browse menu, add to cart, and place orders.
-   **Payment**: Integrated payment flow with QRIS and Cash options, including receipt generation.
-   **Kitchen Display System (KDS)**: Real-time order monitoring for kitchen staff.
-   **Admin Dashboard**: Overview of sales statistics and restaurant performance.

## 🛠 Tech Stack

-   **Framework**: Flutter (Dart)
-   **State Management**: Riverpod
-   **Routing**: GoRouter
-   **Design System**: Custom `AppTheme` with consistent typography and colors.
-   **Mock Backend**: `MockService` for development without a live server.
-   **Networking**: `http` (prepared for REST API integration).

## 🚀 Getting Started

### Prerequisites

-   Flutter SDK (^3.10.0)
-   Dart SDK
-   Android Studio / VS Code

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/restaurant_order_system.git
    cd restaurant_order_system
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the app**
    ```bash
    flutter run
    ```

## 📖 Documentation

Detailed documentation for specific aspects of the project:

-   **[Backend API](BACKEND.md)**: Details on the API endpoints, data models, and integration points.
-   **[Security](SECURITY.md)**: Information on authentication, data storage, and security best practices.

## 🏗 Project Structure

```
lib/
├── core/               # Core utilities (Theme, Router, Services, Constants)
├── features/           # Feature-based modules
│   ├── auth/           # Authentication (Login)
│   ├── tables/         # Table management
│   ├── menu/           # Menu & Product listing
│   ├── cart/           # Shopping cart logic
│   ├── orders/         # Order history & processing
│   ├── payment/        # Payment processing & receipts
│   ├── kitchen/        # Kitchen Display System
│   └── admin/          # Admin Dashboard
└── main.dart           # Entry point
```

## 🔐 Security & Production Notes

This project is currently configured for development with **Mock Data**.
For production deployment, please refer to [SECURITY.md](SECURITY.md) for critical steps regarding:
-   Secure Token Storage (`flutter_secure_storage`)
-   HTTPS Enforcement
-   Data Encryption

## 🤝 Contributing

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request
