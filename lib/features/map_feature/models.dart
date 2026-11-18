import 'package:latlong2/latlong.dart';

class PlaceResult {
  final String name;
  final LatLng location;
  const PlaceResult(this.name, this.location);
}

class RouteResult {
  /// نقاط الخط اللي هيترسم على الخريطة
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  const RouteResult(this.points, this.distanceMeters, this.durationSeconds);
}
