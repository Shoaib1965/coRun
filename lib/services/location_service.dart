import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService with ChangeNotifier {
  bool _isTracking = false;
  List<LatLng> _routeCoords = [];
  double _distance = 0.0;
  DateTime? _startTime;
  Timer? _timer;
  Duration _duration = Duration.zero;

  bool get isTracking => _isTracking;
  double get distance => _distance / 1000; // in km
  double get pace => _distance > 0 ? _duration.inMinutes / (_distance / 1000) : 0;
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
        width: 5,
        points: _routeCoords,
      ),
    };
  }

  Future<void> startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _isTracking = true;
    _startTime = DateTime.now();
    _routeCoords = [];
    _distance = 0;
    _duration = Duration.zero;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration = DateTime.now().difference(_startTime!);
      notifyListeners();
    });

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen((Position position) {
      if (_isTracking) {
        final newLatLng = LatLng(position.latitude, position.longitude);
        
        if (_routeCoords.isNotEmpty) {
          _distance += Geolocator.distanceBetween(
            _routeCoords.last.latitude,
            _routeCoords.last.longitude,
            newLatLng.latitude,
            newLatLng.longitude,
          );
        }
        
        _routeCoords.add(newLatLng);
        notifyListeners();
        
        // Here you would also update Firestore with the new point to "claim territory"
      }
    });
    
    notifyListeners();
  }

  void stopTracking() {
    _isTracking = false;
    _timer?.cancel();
    notifyListeners();
    
    // Save run to Firestore
  }
}
