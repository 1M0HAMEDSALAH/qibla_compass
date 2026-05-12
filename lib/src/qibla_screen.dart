import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qibla_compass/qibla_compass.dart';



/// A full-screen Qibla compass experience.
///
/// Handles location permission, GPS acquisition, and live compass streaming.
///
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const QiblaScreen()),
/// );
/// ```
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({
    super.key,
    this.theme = QiblaTheme.defaultTheme,
    this.locationTimeout = const Duration(seconds: 15),
    this.alignmentThresholdDegrees = 5.0,
  });

  /// Visual theme for the screen.
  final QiblaTheme theme;

  /// How long to wait for a GPS fix before giving up.
  final Duration locationTimeout;

  /// Angle within which the device is considered "aligned" with the Qibla.
  final double alignmentThresholdDegrees;

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  Position? _position;
  double? _qiblaBearing;
  double? _distanceKm;
  String? _errorMessage;

  // ── Animation ──────────────────────────────────────────────────────────────
  late AnimationController _pulseController;
  late AnimationController _fadeInController;
  late Animation<double> _fadeIn;

  bool _wasAligned = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _fadeInController, curve: Curves.easeOut);

    _initialise();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeInController.dispose();
    super.dispose();
  }

  // ── Location logic ─────────────────────────────────────────────────────────

  Future<void> _initialise() async {
    setState(() {
      _errorMessage = null;
      _position = null;
      _qiblaBearing = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _setError('الرجاء تفعيل خدمة الموقع\nPlease enable location services');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setError(
            'يجب السماح بالوصول للموقع\nLocation permission is required');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        widget.locationTimeout,
        onTimeout: () =>
            throw Exception('انتهت مهلة تحديد الموقع\nLocation timed out'),
      );

      setState(() {
        _position = position;
        _qiblaBearing = QiblaCalculator.calculateBearing(
          position.latitude,
          position.longitude,
        );
        _distanceKm = QiblaCalculator.calculateDistanceKm(
          position.latitude,
          position.longitude,
        );
      });

      _fadeInController.forward(from: 0);
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _setError(String msg) => setState(() => _errorMessage = msg);

  void _onAlignmentChanged(bool isAligned) {
    if (isAligned && !_wasAligned) {
      HapticFeedback.mediumImpact();
    }
    _wasAligned = isAligned;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return Scaffold(
      backgroundColor: t.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'اتجاه القبلة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: t.gold,
                fontFamily: 'Amiri',
              ),
            ),
            Text(
              'Qibla Direction',
              style: TextStyle(
                fontSize: 12,
                color: t.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) return _buildError();
    if (_position == null) return _buildLoading();
    return _buildCompassStream();
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    final t = widget.theme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(t.gold),
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'جاري تحديد الموقع…\nDetecting location…',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.textSecondary,
              fontSize: 16,
              fontFamily: 'Amiri',
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError() {
    final t = widget.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined, color: t.gold, size: 64),
            const SizedBox(height: 24),
            Text(
              _errorMessage ?? 'حدث خطأ\nAn error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: t.textPrimary,
                fontSize: 17,
                height: 1.6,
                fontFamily: 'Amiri',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _initialise,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'إعادة المحاولة / Retry',
                style: TextStyle(
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: t.gold,
                foregroundColor: t.backgroundDark,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Compass stream ─────────────────────────────────────────────────────────

  Widget _buildCompassStream() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildLoading();

        final heading = snapshot.data!.heading;
        if (heading == null) {
          return _buildError();
        }

        final isAligned = QiblaCalculator.isAligned(
          _qiblaBearing!,
          heading,
          thresholdDegrees: widget.alignmentThresholdDegrees,
        );

        _onAlignmentChanged(isAligned);

        return FadeTransition(
          opacity: _fadeIn,
          child: _buildCompassLayout(heading, isAligned),
        );
      },
    );
  }

  Widget _buildCompassLayout(double heading, bool isAligned) {
    final t = widget.theme;

    return Column(
      children: [
        const SizedBox(height: 12),

        // ── Info strip ────────────────────────────────────────────────────────
        _InfoStrip(
          position: _position!,
          distanceKm: _distanceKm!,
          qiblaBearing: _qiblaBearing!,
          theme: t,
        ),

        // ── Compass ───────────────────────────────────────────────────────────
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulse ring when aligned
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isAligned)
                      FadeTransition(
                        opacity: _pulseController,
                        child: Container(
                          width: 308,
                          height: 308,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: t.gold, width: 1.5),
                          ),
                        ),
                      ),
                    QiblaCompassWidget(
                      qiblaBearing: _qiblaBearing!,
                      deviceHeading: heading,
                      size: 280,
                      theme: t,
                      alignmentThresholdDegrees:
                          widget.alignmentThresholdDegrees,
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // ── Alignment badge ───────────────────────────────────────────
                _AlignmentBadge(isAligned: isAligned, theme: t),

                const SizedBox(height: 16),

                // ── Bearing text ──────────────────────────────────────────────
                Text(
                  '${_qiblaBearing!.toStringAsFixed(1)}°',
                  style: TextStyle(
                    color: t.gold,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Calibration hint ──────────────────────────────────────────────────
        _CalibrationHint(theme: t),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({
    required this.position,
    required this.distanceKm,
    required this.qiblaBearing,
    required this.theme,
  });

  final Position position;
  final double distanceKm;
  final double qiblaBearing;
  final QiblaTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoCell(
            icon: Icons.map_outlined,
            label: 'المسافة\nDistance',
            value: '${distanceKm.toStringAsFixed(0)} km',
            theme: theme,
          ),
          _Divider(theme: theme),
          _InfoCell(
            icon: Icons.my_location_outlined,
            label: 'خط العرض\nLatitude',
            value: '${position.latitude.toStringAsFixed(4)}°',
            theme: theme,
          ),
          _Divider(theme: theme),
          _InfoCell(
            icon: Icons.explore_outlined,
            label: 'خط الطول\nLongitude',
            value: '${position.longitude.toStringAsFixed(4)}°',
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.theme});
  final QiblaTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: theme.cardBorder,
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final QiblaTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: theme.accentCyan, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 9,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _AlignmentBadge extends StatelessWidget {
  const _AlignmentBadge({required this.isAligned, required this.theme});
  final bool isAligned;
  final QiblaTheme theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: isAligned
            ? theme.gold.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isAligned ? theme.gold : Colors.white30,
          width: 1.5,
        ),
        boxShadow: isAligned
            ? [
                BoxShadow(
                  color: theme.gold.withValues(alpha: 0.25),
                  blurRadius: 16,
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAligned ? Icons.check_circle_outline : Icons.screen_rotation,
            color: isAligned ? theme.gold : Colors.white60,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            isAligned
                ? 'الاتجاه صحيح ✓\nCorrectly Aligned'
                : 'استمر بالتدوير\nKeep Rotating',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isAligned ? theme.gold : theme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalibrationHint extends StatelessWidget {
  const _CalibrationHint({required this.theme});
  final QiblaTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'للدقة: حرك الهاتف على شكل رقم 8\n'
              'For accuracy: Move phone in a figure-8 pattern',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
