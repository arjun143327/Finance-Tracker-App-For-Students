# 📊 Budgetrix — Personal Finance & Smart Budgeting

Budgetrix is a premium, high-fidelity personal finance tracker tailored for students and budget-conscious individuals. It focuses on beautiful, responsive design systems, tactile swipe micro-animations, on-device AI voice parsing, and fully offline local ledger extraction.

---

## ✨ Premium Highlights & Features

### 🎙️ 1. Smart Local Voice Input & Waveforms
*   **On-Device AI parsing**: Speak to add expenses seamlessly (e.g., *"Spent 500 rupees on dinner"*).
*   **Tactile Waveform Visualizer**: A fluid, real-time audio wave visualization built directly into the voice modal.
*   **No API Keys**: Fully on-device engine using native system speech recognition, keeping everything private and network-independent.

### 📱 2. Automated Local SMS Ledger Parsing
*   **Zero-Latency Intake**: Securely intercepts incoming transactional bank SMS alerts and automatically extracts the amount, merchant, and category.
*   **Completely Offline**: Processes text alerts directly on the device using native telephony streams—no external APIs or servers involved.

### 📈 3. Interactive Insights & Glassmorphic Tooltips
*   **Interactive Spending Charts**: Tap-to-inspect custom visual graphs built with `fl_chart`.
*   **Glassmorphic Detail Cards**: Sleek hover/touch tooltips dynamically highlighting specific day-to-day spending metrics.

### 🔔 4. Smart Category Budget Warnings
*   **Intelligent Threshold Triggers**: Real-time push notifications when category spending hits **80%** (Warning) or **100%** (Critical Limit) of your budget.
*   **Visual Indicators**: Premium progress gauges that transition colors dynamically based on budget depletion.

### 👈 5. tactile Swipe Action Sheets
*   **Tactile Micro-Animations**: Smooth, glassmorphic swipe action sliders to quickly edit or delete transaction items right from the dashboard ledger.

---

## 🔒 Security & Privacy First

Budgetrix is built on a **fully sandboxed offline architecture**:
*   **SQLite Database**: Your complete transaction ledger resides safely inside the mobile OS's secure device sandbox.
*   **No Cloud Leaks**: Zero network calls, zero tracking analytics, and absolutely **no API keys** are bundled or sent over the internet.
*   **Permission Transparency**: Standard system permissions are requested strictly for local capabilities (Microphone for voice, SMS Broadcast for transaction parsing, and Push Notifications for budget warnings).

---

## 🛠️ Technical Stack & Architecture

*   **Framework**: Flutter (iOS & Android compilation target)
*   **State Management**: `flutter_riverpod` (Dynamic, unidirectional data streams)
*   **Local Database**: `sqflite` (Robust, lightweight SQL engine)
*   **Interactive Charts**: `fl_chart`
*   **Local Notifications**: `flutter_local_notifications`

---

## 🚀 Getting Started

### 📋 Prerequisites
*   **Flutter SDK**: `>=3.16.7 <4.0.0`
*   **Android Studio / Xcode**
*   **Windows Developer Mode**: Must be toggled **ON** to support Flutter dependency symlinks during package updates.

### 📥 Installation & Running

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/yourusername/Budgetrix.git
    cd Budgetrix
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Generate Launcher Icons**:
    ```bash
    flutter pub run flutter_launcher_icons
    ```

4.  **Run the Project**:
    ```bash
    flutter run
    ```

5.  **Build Release APK**:
    ```bash
    flutter build apk
    ```

---

## 📁 Repository Structure

```
lib/
├── data/
│   └── models/          # Data Models (Transaction, Category, Profile)
├── presentation/
│   ├── screens/         # Screens (Dashboard, Insights, AddExpense, etc.)
│   └── widgets/         # Custom Premium Reusable UI Widgets
├── services/
│   ├── database/        # SQLite Database Services
│   ├── notification/    # Local Budget Alert Triggers
│   ├── sms/             # Incoming SMS Transaction Parser
│   └── voice/           # Speech-To-Text AI Parsing Engine
└── main.dart            # Application Entry Point
```
