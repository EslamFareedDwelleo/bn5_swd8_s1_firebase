import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'map_service.dart';
import 'models.dart';

/// تنفيذ مجاني: Nominatim للبحث + OSRM للطرق.
/// تنبيه: السيرفرات العامة للتجربة فقط، للإنتاج استخدم مزوّد بمفتاح
/// (OpenRouteService / MapTiler ...) أو استضف OSRM بنفسك.
class OsmMapService implements MapService {
  /// غيّره لاسم تطبيقك (Nominatim بيطلب User-Agent مميز)
  final String userAgent;
  final http.Client _client;

  OsmMapService({this.userAgent = 'my_flutter_app/1.0'})
      : _client = http.Client();

  @override
  Future<List<PlaceResult>> searchPlace(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': q,
      'format': 'json',
      'limit': '6',
      'accept-language': 'ar,en',
    });

    final res = await _client
        .get(uri, headers: {'User-Agent': userAgent})
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      throw Exception('فشل البحث (${res.statusCode})');
    }

    final List data = jsonDecode(res.body);
    return data
        .map((e) => PlaceResult(
              e['display_name'] as String,
              LatLng(double.parse(e['lat']), double.parse(e['lon'])),
            ))
        .toList();
  }

  @override
  Future<RouteResult> getRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      throw Exception('محتاج نقطتين على الأقل');
    }

    // OSRM بياخد lon,lat (عكس LatLng)
    final coords =
        waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$coords'
      '?overview=full&geometries=geojson',
    );

    final res = await _client
        .get(uri, headers: {'User-Agent': userAgent})
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('فشل حساب الطريق (${res.statusCode})');
    }

    final body = jsonDecode(res.body);
    if (body['code'] != 'Ok' || (body['routes'] as List).isEmpty) {
      throw Exception('مفيش طريق متاح بين النقاط دي');
    }

    final route = body['routes'][0];
    final List line = route['geometry']['coordinates'];

    return RouteResult(
      line
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList(),
      (route['distance'] as num).toDouble(),
      (route['duration'] as num).toDouble(),
    );
  }
}
