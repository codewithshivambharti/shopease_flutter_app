# ShopEase - Flutter E-Commerce App

A full-featured Flutter e-commerce app with Firebase backend and Razorpay payment integration.

## Features
- 🔐 Firebase Authentication (Email/Password)
- 🛍️ Product listing with categories, search & filters
- 🛒 Shopping cart with quantity management
- ❤️ Wishlist
- 💳 Razorpay payment integration 
- 📦 Order tracking
- 👤 User profile management
- 🌙 Dark mode support
- 📱 Fully responsive UI

## Project Structure
```
lib/
├── main.dart
├── firebase_options.dart
├── models/          # Data models (Product, User, Order, CartItem)
├── providers/       # State management (Auth, Cart, Orders, Wishlist)
├── screens/
│   ├── auth/        # Splash, Login, Register
│   ├── home/        # Home screen with banners & categories
│   ├── products/    # Product listing & detail
│   ├── cart/        # Cart & Checkout (Razorpay)
│   ├── orders/      # Order history
│   ├── wishlist/    # Saved products
│   └── profile/     # User profile
├── widgets/         # Reusable ProductCard widget
└── utils/           # Theme & constants
```
