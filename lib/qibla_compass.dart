/// A beautifully designed Flutter Qibla compass package.
///
/// Provides a full-screen [QiblaScreen] widget and a lower-level
/// [QiblaCompassWidget] for embedding in your own UI.
///
/// Usage:
/// ```dart
/// import 'package:qibla_compass/qibla_compass.dart';
///
/// // Full screen:
/// Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaScreen()));
///
/// // Embedded widget:
/// QiblaCompassWidget(size: 280)
/// ```
library qibla_compass;

export 'src/qibla_screen.dart';
export 'src/qibla_compass_widget.dart';
export 'src/qibla_calculator.dart';
export 'src/qibla_theme.dart';
