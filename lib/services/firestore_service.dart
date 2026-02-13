import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  FirebaseFirestore? _db;
  bool _isOffline = false;

  // Mock Data
  final List<Territory> _mockRuns = [];

  FirestoreService() {
    try {
      _db = FirebaseFirestore.instance;
    } catch (e) {
      print('FirestoreService running in Offline Mode');
      _isOffline = true;
    }
  }

  // Save completed run
  Future<void> saveRun(String userId, List<LatLng> route, double distance, Duration duration) async {
    if (route.isEmpty) return;

    if (_isOffline) {
      await Future.delayed(const Duration(milliseconds: 500));
      _mockRuns.add(Territory(
        id: 'mock_run_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        points: route,
      ));
      return;
    }

    try {
      // Convert to simple map list for Firestore
      final points = route.map((p) => {
        'lat': p.latitude, 
        'lng': p.longitude
      }).toList();

      await _db!.collection('runs').add({
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'distance': distance,
        'durationSeconds': duration.inSeconds,
        'points': points,
      });

      // Update aggregate stats
      await _db!.collection('users').doc(userId).set({
        'totalDistance': FieldValue.increment(distance),
        'runCount': FieldValue.increment(1),
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint('Error saving run: $e');
    }
  }

  // Get recent territories (runs)
  Stream<List<Territory>> get territories {
    if (_isOffline) {
      // Return a stream that emits current mock runs and updates when saveRun happens?
      // Simple behavior: just emit once or fake it.
      // Better: Use a StreamController if needed, but for now just return mock list.
      return Stream.value(_mockRuns);
    }

    return _db!.collection('runs')
        .orderBy('timestamp', descending: true)
        .limit(50) 
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final List<dynamic> pointsData = data['points'] ?? [];
            final points = pointsData.map((p) => LatLng(p['lat'], p['lng'])).toList();
            
            return Territory(
              id: doc.id,
              userId: data['userId'],
              points: points,
            );
          }).toList();
        });
  }
}

class Territory {
  final String id;
  final String userId;
  final List<LatLng> points;

  Territory({required this.id, required this.userId, required this.points});
}
