import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService with ChangeNotifier {
  bool _isTracking = false;
  List<LatLng> _routeCoords = [];
  double _distance = 0.0; // in meters
  DateTime? _startTime;
  Timer? _timer;
  Duration _duration = Duration.zero;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Getters
  bool get isTracking => _isTracking;
  List<LatLng> get routeCoords => _routeCoords;
  Duration get duration => _duration;
  double get distanceKm => _distance / 1000.0;
  double get distanceMeters => _distance;
  LatLng? get currentLocation => _routeCoords.isNotEmpty ? _routeCoords.last : null;
  
  // Pace in min/km
  double get pace {
    if (_distance == 0) return 0;
    double minutes = _duration.inSeconds / 60.0;
    double km = _distance / 1000.0;
    return minutes / km;
  }

  String get formattedTime {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_duration.inMinutes.remainder(60));
    final seconds = twoDigits(_duration.inSeconds.remainder(60));
    return "${twoDigits(_duration.inHours)}:$minutes:$seconds";
  }

  Set<Polyline> get polylines {
    return {
      Polyline(
        polylineId: const PolylineId('current_run'),
        color: const Color(0xFF00FF88),
        width: 6,
        points: _routeCoords,
        jointType: JointType.round,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
      ),
    };
  }

  // Get current position stream removed (unused)

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) {
      // TODO: Handle permanently denied (open settings)
      return false;
    }
    return true;
  }

  Future<void> startTracking() async {
    bool hasPermission = await requestPermission();
    if (!hasPermission) return;

    _isTracking = true;
    _startTime = DateTime.now();
    _routeCoords = [];
    _distance = 0;
    _duration = Duration.zero;
    
    // Start Timer
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration = DateTime.now().difference(_startTime!);
      notifyListeners();
    });

    // Start GPS Stream
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen((Position position) {
      if (!_isTracking) return;

      final newLatLng = LatLng(position.latitude, position.longitude);
      
      if (_routeCoords.isNotEmpty) {
        final dist = Geolocator.distanceBetween(
          _routeCoords.last.latitude,
          _routeCoords.last.longitude,
          newLatLng.latitude,
          newLatLng.longitude,
        );
        _distance += dist;
      }
      
      _routeCoords.add(newLatLng);
      notifyListeners();
    });
    
    notifyListeners();
  }

  void stopTracking() {
    _isTracking = false;
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
