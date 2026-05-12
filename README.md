# qibla_compass 🕌

A beautifully designed, production-ready Flutter package for showing the Qibla (direction of the Kaaba in Mecca) using the device's GPS and compass sensor.

---

## Features

| Feature | Detail |
|---------|--------|
| 🧭 Live compass | Streams real-time heading from `flutter_compass` |
| 📍 GPS location | Uses `geolocator` with full permission handling |
| ✨ Smooth animation | Animated needle with shortest-path interpolation (no 0/360 spin) |
| 📳 Haptic feedback | Single pulse when the device aligns with the Qibla |
| 🎨 Theming | Built-in `defaultTheme` and `midnightTheme`; fully customisable |
| 🌍 Bilingual | Arabic + English labels throughout |
| 📦 Embeddable | `QiblaCompassWidget` can be dropped into any screen |
| ✅ Tested | Unit tests for all Qibla calculations |

---

## Getting Started

### 1. Add dependency

```yaml
dependencies:
  qibla_compass:
    path: ../qibla_compass   # or your pub.dev version
```

### 2. Android permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 3. iOS permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to calculate Qibla direction</string>
```

---

## Usage

### Full-screen (recommended)

```dart
import 'package:qibla_compass/qibla_compass.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const QiblaScreen()),
);
```

### Custom theme

```dart
QiblaScreen(theme: QiblaTheme.midnightTheme)
```

### Embedded compass widget

Use `QiblaCompassWidget` if you want to integrate the compass dial into your own screen:

```dart
StreamBuilder<CompassEvent>(
  stream: FlutterCompass.events,
  builder: (context, snapshot) {
    final heading = snapshot.data?.heading ?? 0;
    return QiblaCompassWidget(
      qiblaBearing: QiblaCalculator.calculateBearing(lat, lng),
      deviceHeading: heading,
      size: 240,
    );
  },
);
```

### Pure calculation

```dart
// Bearing in degrees from true North (0–360)
final bearing = QiblaCalculator.calculateBearing(30.0444, 31.2357); // Cairo → ~135°

// Distance to Mecca in km
final km = QiblaCalculator.calculateDistanceKm(30.0444, 31.2357); // ~1290 km

// Are we aligned?
final aligned = QiblaCalculator.isAligned(bearing, deviceHeading); // default ±5°
```

---

## Theming

```dart
// Use a built-in theme
const QiblaScreen(theme: QiblaTheme.midnightTheme)

// Or create your own
const myTheme = QiblaTheme(
  backgroundDark: Color(0xFF1A0A2E),
  backgroundMid:  Color(0xFF2E0F3E),
  gold:           Color(0xFFE8C96A),
  compassFaceStart: Color(0xFF3A1A6C),
  compassFaceEnd:   Color(0xFF1A0A2E),
);

QiblaScreen(theme: myTheme)
```

### `QiblaTheme` properties

| Property | Default | Description |
|----------|---------|-------------|
| `backgroundDark` | `#0A2E24` | Outermost background |
| `backgroundMid` | `#0F3E33` | Secondary background |
| `gold` | `#CDA047` | Primary accent (needle, bearing text, badges) |
| `compassFaceStart` | `#1A5C4A` | Compass centre gradient start |
| `compassFaceEnd` | `#0A2E24` | Compass centre gradient end |
| `northIndicator` | `#FF4757` | Colour of the "N" tick |
| `accentCyan` | `#00D9FF` | Info-strip icon colour |

---

## Running tests

```bash
flutter test
```

---

## Accuracy notes

- Accuracy depends on the device's magnetometer hardware.
- Ask the user to perform a **figure-8 calibration** motion before use (the UI hints at this).
- `alignmentThresholdDegrees` (default `5°`) can be tightened or loosened:

```dart
QiblaScreen(alignmentThresholdDegrees: 3.0)  // stricter
```

---

## License

MIT © 2024
