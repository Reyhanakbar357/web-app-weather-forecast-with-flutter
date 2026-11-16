# 🌤️ SkyView Pro - Weather Forecast App

A modern, responsive, real-time weather forecasting application built with **Flutter**, featuring interactive live maps, weather radar, multi-city comparisons, and deep space aurora dark theme.

---

## ✨ Features

- 🌍 **Interactive World Map**: Live weather inspection anywhere on the globe powered by **Esri World Dark Canvas** tiles.
- 📡 **Interactive Weather Radar**: Real-time multi-layer simulation for rain, clouds, temperature, wind, and visibility.
- 🏙️ **Multi-City Comparison**: Compare weather conditions, temperatures, and metrics across different cities simultaneously.
- ⭐ **Favorites & Search History**: Quick access to saved locations with offline caching.
- 📱 **Fully Responsive**: Seamless layout across Mobile, Tablet, and Desktop Web browsers.
- 🌙 **Deep Space Aurora UI**: Sleek glassmorphism design with vibrant neon accents.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.24.0 or higher)
- Dart SDK

### Setup & Run

1. Clone this repository:
   ```bash
   git clone https://github.com/Reyhanakbar357/web-app-weather-forecast-with-flutter.git
   cd web-app-weather-forecast-with-flutter
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Setup your OpenWeatherMap API Key:
   - Get a free API key at [OpenWeatherMap](https://openweathermap.org/api).
   - Either pass it at runtime:
     ```bash
     flutter run -d chrome --dart-define=OPENWEATHER_API_KEY=your_api_key_here
     ```
   - Or replace `'YOUR_OPENWEATHER_API_KEY'` directly in `lib/core/constants/app_constants.dart`.

4. Run the app:
   ```bash
   flutter run -d chrome
   ```

---

## 🛠️ Built With

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Maps**: [flutter_map](https://pub.dev/packages/flutter_map) + Esri ArcGIS Canvas
- **Typography**: [Google Fonts (Syne & Plus Jakarta Sans)](https://fonts.google.com)
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate)
