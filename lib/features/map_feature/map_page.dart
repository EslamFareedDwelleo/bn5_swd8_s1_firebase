import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'location_helper.dart';
import 'map_service.dart';
import 'models.dart';
import 'osm_map_service.dart';

class MapPage extends StatefulWidget {
  /// تقدر تمرر أي MapService تاني (Google مثلًا)
  final MapService? service;
  const MapPage({super.key, this.service});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapService _service = widget.service ?? OsmMapService();
  final MapController _controller = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  static const Distance _distance = Distance();

  final List<LatLng> _markers = [];
  List<LatLng> _routePoints = [];
  RouteResult? _route;
  LatLng? _myLocation;
  List<PlaceResult> _results = [];
  bool _searching = false;
  bool _routing = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _clearRoute() {
    _routePoints = [];
    _route = null;
  }

  // ---------- Markers ----------
  void _addMarker(LatLng p) {
    setState(() {
      _markers.add(p);
      _clearRoute(); // الطريق القديم مبقاش صالح
    });
  }

  void _removeMarker(int i) {
    setState(() {
      _markers.removeAt(i);
      _clearRoute();
    });
  }

  void _clearAll() {
    setState(() {
      _markers.clear();
      _results = [];
      _clearRoute();
    });
  }

  // ---------- Search ----------
  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _searching = true);
    try {
      final r = await _service.searchPlace(q);
      setState(() => _results = r);
      if (r.isEmpty) _toast('مفيش نتائج');
    } catch (e) {
      _toast('$e');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectResult(PlaceResult place) {
    _addMarker(place.location);
    setState(() => _results = []);
    _controller.move(place.location, 15);
  }

  // ---------- Route ----------
  Future<void> _drawRoute() async {
    if (_markers.length < 2) {
      _toast('حط نقطتين على الأقل (اضغط على الخريطة أو ابحث)');
      return;
    }
    setState(() => _routing = true);
    try {
      final r = await _service.getRoute(_markers);
      setState(() {
        _route = r;
        _routePoints = r.points;
      });
      _controller.fitCamera(
        CameraFit.coordinates(
          coordinates: r.points,
          padding: const EdgeInsets.fromLTRB(40, 160, 40, 160),
        ),
      );
    } catch (e) {
      _toast('$e');
    } finally {
      if (mounted) setState(() => _routing = false);
    }
  }

  // ---------- My location ----------
  Future<void> _goToMyLocation() async {
    try {
      final p = await LocationHelper.getCurrentLatLng();
      setState(() => _myLocation = p);
      _controller.move(p, 15);
    } catch (e) {
      _toast('$e');
    }
  }

  void _addMyLocationAsMarker() {
    if (_myLocation != null) _addMarker(_myLocation!);
  }

  // ---------- Formatting ----------
  String _fmtDistance(double meters) => meters >= 1000
      ? '${(meters / 1000).toStringAsFixed(1)} كم'
      : '${meters.round()} متر';

  String _fmtDuration(double seconds) {
    final m = (seconds / 60).round();
    if (m < 60) return '$m دقيقة';
    return '${m ~/ 60} س ${m % 60} د';
  }

  String? get _infoText {
    final parts = <String>[];
    if (_markers.length >= 2) {
      final straight = _distance(_markers.first, _markers.last);
      parts.add('مسافة مباشرة: ${_fmtDistance(straight)}');
    }
    if (_route != null) {
      parts.add('بالطريق: ${_fmtDistance(_route!.distanceMeters)}'
          ' • ${_fmtDuration(_route!.durationSeconds)}');
    }
    return parts.isEmpty ? null : parts.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final info = _infoText;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: const LatLng(30.0444, 31.2357), // القاهرة
              initialZoom: 12,
              onTap: (_, point) => _addMarker(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // غيّره لـ package name بتاع تطبيقك
                userAgentPackageName: 'com.example.myapp',
              ),
              PolylineLayer(
                polylines: [
                  if (_routePoints.isNotEmpty)
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5,
                      color: Colors.blue,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (_myLocation != null)
                    Marker(
                      point: _myLocation!,
                      width: 24,
                      height: 24,
                      child: const Icon(Icons.my_location,
                          color: Colors.blue, size: 24),
                    ),
                  for (var i = 0; i < _markers.length; i++)
                    Marker(
                      point: _markers[i],
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => _removeMarker(i), // اضغط للحذف
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.red, size: 44),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // ---- Search ----
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    child: TextField(
                      controller: _searchCtrl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن مكان...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                        suffixIcon: _searching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: _search,
                              ),
                      ),
                    ),
                  ),
                  if (_results.isNotEmpty)
                    Card(
                      elevation: 4,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 260),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.place_outlined),
                            title: Text(
                              _results[i].name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectResult(_results[i]),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ---- Info card ----
          if (info != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: SafeArea(
                child: Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(info, style: const TextStyle(fontSize: 15)),
                  ),
                ),
              ),
            ),
        ],
      ),

      // ---- Buttons ----
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: info != null ? 90 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: 'clear',
              tooltip: 'مسح الكل',
              onPressed: _clearAll,
              child: const Icon(Icons.delete_outline),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'addMe',
              tooltip: 'أضف موقعي كنقطة',
              onPressed: _myLocation == null ? null : _addMyLocationAsMarker,
              child: const Icon(Icons.add_location_alt_outlined),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'me',
              tooltip: 'موقعي',
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'route',
              tooltip: 'ارسم الطريق',
              onPressed: _routing ? null : _drawRoute,
              child: _routing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.directions),
            ),
          ],
        ),
      ),
    );
  }
}
