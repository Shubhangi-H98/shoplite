# 🛒 ShopLite - E-Commerce Catalog App

A high-performance, **Offline-First** E-commerce catalog application built with Flutter, following **Layered Clean Architecture** and **SOLID principles**.

---

## 🚀 Key Features Implemented
- **Layered Clean Architecture**: Strict separation of concerns (Data, Domain, Presentation).
- **State Management**: Robust state handling using **BLoC/Cubit**.
- **Smart Caching (Offline First)**: Integrated **Hive** with a **30-minute TTL (Time-To-Live)** strategy to ensure fresh data while allowing offline access.
- **Dependency Injection**: Decoupled components using **GetIt** for better testability.
- **Theming**: Full support for **Dynamic Light & Dark Modes**.
- **Branding**: Customized **Native Splash Screen** and **Launcher Icons**.
- **Catalog Management**: Real-time Search, Category Filtering, and Pagination logic.

---

## 🏗️ Architecture Overview
The app is divided into three main layers to ensure scalability and maintainability:

| Layer | Responsibility |
| :--- | :--- |
| **Presentation** | UI Widgets, Themes, and BLoC/Cubit for state handling. |
| **Domain** | Business Logic, Abstract Repositories, and Entities. |
| **Data** | API implementations (Dio), DTOs (Models), and Local Persistence (Hive). |

---

## 🧪 Testing Strategy
I have followed a rigorous testing approach to ensure the reliability of critical business logic and UI:
- **Unit Tests**: Validated the `ProductRepository` logic, covering successful API fetches, Hive caching, and offline fallback mechanisms.
- **Widget Tests**: Verified the `SplashPage` and `Smoke Tests` for initial app loading and branding presence.

**Current Status:** `All tests passed!` ✅

---

## 🛠️ Tech Stack & Tools
- **Core**: Flutter SDK
- **State Management**: flutter_bloc
- **Networking**: Dio (ApiClient wrapper)
- **Local Database**: Hive & Hive Flutter
- **Secure Storage**: Flutter Secure Storage (for Cache Timestamps)
- **Dependency Injection**: GetIt
- **Testing**: flutter_test, bloc_test, mocktail

---

## 📂 Project Structure
```text
lib/
├── core/               # Network Client, Common Utils, Global Themes
├── features/           # Feature-based modular structure
│   ├── auth/           # Login & Session Management
│   ├── catalog/        # Product List, Search, & Details
│   └── splash/         # Branding & Auth Initialization
├── injection_container.dart # Dependency Injection Setup
└── main.dart           # App Entry Point & Global Providers


## 🧩 Architecture Diagram (Clean Architecture)

[Image of Flutter Clean Architecture layers: Data, Domain, and Presentation]

```mermaid
graph TD
    UI[Presentation: Widgets] --> Cubit[Presentation: Cubit/BLoC]
    Cubit --> UseCase[Domain: Use Cases]
    UseCase --> RepoInterface[Domain: Repository Interface]
    RepoInterface --> RepoImpl[Data: Repository Implementation]
    RepoImpl --> API[Data: Remote API Source]
    RepoImpl --> Local[Data: Local Hive Storage]
