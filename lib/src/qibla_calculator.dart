import 'dart:math';

/// Coordinates of the Kaaba in Mecca, Saudi Arabia.
const double kKaabaLatitude = 21.422510;
const double kKaabaLongitude = 39.826168;

/// Pure calculation utilities for Qibla direction.
class QiblaCalculator {
  QiblaCalculator._();

  /// Calculates the Qibla bearing in degrees (0–360) from true North,
  /// given the user's [latitude] and [longitude] in decimal degrees.
  ///
  /// Uses the spherical law of cosines (great-circle bearing).
  static double calculateBearing(double latitude, double longitude) {
    final lat1 = latitude * pi / 180;
    final lat2 = kKaabaLatitude * pi / 180;
    final dLon = (kKaabaLongitude - longitude) * pi / 180;

    final y = sin(dLon);
    final x = cos(lat1) * tan(lat2) - sin(lat1) * cos(dLon);

    final bearing = atan2(y, x);
    return (bearing * 180 / pi + 360) % 360;
  }

  /// Calculates the great-circle distance in kilometres between the user's
  /// location and the Kaaba, using the Haversine formula.
  static double calculateDistanceKm(double latitude, double longitude) {
    const earthRadius = 6371.0;
    final dLat = (kKaabaLatitude - latitude) * pi / 180;
    final dLon = (kKaabaLongitude - longitude) * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(latitude * pi / 180) *
            cos(kKaabaLatitude * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  /// Returns `true` when the device heading is within [thresholdDegrees]
  /// of the Qibla bearing.
  static bool isAligned(
    double qiblaBearing,
    double deviceHeading, {
    double thresholdDegrees = 5.0,
  }) {
    double diff = (qiblaBearing - deviceHeading).abs() % 360;
    if (diff > 180) diff = 360 - diff;
    return diff < thresholdDegrees;
  }
}
