import 'package:flutter_test/flutter_test.dart';
import 'package:qibla_compass/qibla_compass.dart';

void main() {
  group('QiblaCalculator', () {
    // --- bearing ---
    test('bearing from Cairo is approximately 135° (SE)', () {
      // Cairo: 30.0444° N, 31.2357° E
      final bearing = QiblaCalculator.calculateBearing(30.0444, 31.2357);
      expect(bearing, closeTo(135, 5));
    });

    test('bearing from London is approximately 119°', () {
      // London: 51.5074° N, -0.1278° W
      final bearing = QiblaCalculator.calculateBearing(51.5074, -0.1278);
      expect(bearing, closeTo(119, 5));
    });

    test('bearing from New York is approximately 58°', () {
      // New York: 40.7128° N, -74.0060° W
      final bearing = QiblaCalculator.calculateBearing(40.7128, -74.006);
      expect(bearing, closeTo(58, 5));
    });

    test('bearing from Mecca itself returns any value without throwing', () {
      expect(
        () => QiblaCalculator.calculateBearing(21.422510, 39.826168),
        returnsNormally,
      );
    });

    // --- distance ---
    test('distance from Cairo to Mecca is approximately 1290 km', () {
      final dist = QiblaCalculator.calculateDistanceKm(30.0444, 31.2357);
      expect(dist, closeTo(1290, 50));
    });

    test('distance from London to Mecca is approximately 5760 km', () {
      final dist = QiblaCalculator.calculateDistanceKm(51.5074, -0.1278);
      expect(dist, closeTo(5760, 100));
    });

    // --- alignment ---
    test('isAligned returns true when within threshold', () {
      expect(QiblaCalculator.isAligned(135, 132), isTrue);
    });

    test('isAligned returns false when outside threshold', () {
      expect(QiblaCalculator.isAligned(135, 120), isFalse);
    });

    test('isAligned handles 0/360 wraparound correctly', () {
      expect(QiblaCalculator.isAligned(2, 358), isTrue);
    });
  });
}
