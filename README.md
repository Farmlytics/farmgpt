# farmlytics

🌱 **Smart Agriculture Analytics Platform**

Farmlytics is a modern Flutter application designed to revolutionize agricultural data analysis and farm management. Built with cutting-edge technology and a focus on user experience, it provides farmers and agricultural professionals with powerful tools to optimize their operations.

## 🌟 Features

### 📊 **Analytics Dashboard**
- Real-time farm data visualization
- Performance metrics and insights
- Historical data tracking
- Customizable reporting

### 🎨 **Modern Design**
- Clean, intuitive user interface
- Dark theme optimized for outdoor use
- Responsive design across all devices
- Smooth animations and transitions

### 📱 **Cross-Platform Support**
- **Android** - Native performance with adaptive icons
- **iOS** - Optimized for iPhone and iPad
- **Web** - Progressive Web App capabilities
- **Desktop** - Windows, macOS, and Linux support

### 🔧 **Technical Features**
- **Adaptive Icons** - Supports Android 13+ themed icons
- **Custom Typography** - Funnel Display font family
- **Lottie Animations** - Engaging plant growth animations
- **Shared Preferences** - Local data persistence
- **Splash Screen** - Professional app introduction

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- VS Code (recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/farmlytics.git
   cd farmlytics
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate app icons**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Platform-Specific Setup

### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Adaptive icons with themed support
- Package: `com.farmlytics.app`

### iOS
- Minimum iOS: 12.0
- Supports iPhone and iPad
- App Store compliant icons
- Bundle ID: `com.farmlytics.app`

### Web
- Progressive Web App (PWA) ready
- Responsive design
- Service worker support
- Manifest configuration

## 🎨 Design System

### Typography
- **Primary Font**: Funnel Display
  - Modern, clean neo-grotesque typeface
  - Weights: Regular (400), Bold (700)
  - Optimized for readability

### Color Palette
- **Primary Green**: `#1FBA55`
- **Background**: Dark theme optimized
- **Text**: High contrast white/light colors
- **Accents**: Eco-friendly green tones

### Icons
- Custom app icon with green background
- Monochrome version for themed icons
- Eco-themed iconography
- Adaptive icon support

## 🏗️ Project Structure

```
lib/
├── main.dart              # App entry point
├── splash.dart            # Animated splash screen
├── MainPage.dart          # Main application interface
└── ...

assets/
├── icon/                  # App icons
│   ├── icon.png          # Main app icon
│   └── icon_mono.png     # Monochrome version
├── animations/            # Lottie animations
│   └── plant.json        # Plant growth animation
└── fonts/                # Custom fonts
    └── Funnel_Display/   # Primary typeface
```

## 🔧 Configuration

### App Icons
The app uses `flutter_launcher_icons` for automatic icon generation:
- Source: `assets/icon/icon.png`
- Background: `#1FBA55`
- Monochrome: `assets/icon/icon_mono.png`
- Supports all platforms and densities

### Dependencies
- `animated_splash_screen`: Professional splash animations
- `lottie`: Vector animations
- `shared_preferences`: Local data storage
- `flutter_launcher_icons`: Icon generation

## 📈 Development

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS App:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

### Code Quality
- Flutter Lints enabled
- Consistent code formatting
- Type safety with Dart
- Responsive design patterns

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test across platforms
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌱 About Farmlytics

Farmlytics represents the future of agricultural technology, combining modern mobile development with practical farming needs. Our mission is to empower farmers with data-driven insights to improve crop yields, reduce waste, and promote sustainable agriculture.

### Vision
To become the leading platform for agricultural analytics, helping farmers worldwide make informed decisions through technology.

### Values
- **Sustainability** - Promoting eco-friendly farming practices
- **Innovation** - Leveraging cutting-edge technology
- **Accessibility** - Making advanced tools available to all farmers
- **Reliability** - Providing consistent, accurate data

---

**Built with ❤️ for the agricultural community**

*Empowering farmers through technology*