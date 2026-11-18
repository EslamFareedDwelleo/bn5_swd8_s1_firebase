import 'package:latlong2/latlong.dart';
import 'models.dart';

/// واجهة مجردة: لو عاوز تبدّل المزوّد (Google / ORS / Mapbox)
/// اعمل class جديد يimplement الواجهة دي وخلاص.
abstract class MapService {
  Future<List<PlaceResult>> searchPlace(String query);

  /// طريق يمر بالنقاط بالترتيب (نقطتين أو أكتر)
  Future<RouteResult> getRoute(List<LatLng> waypoints);
}
