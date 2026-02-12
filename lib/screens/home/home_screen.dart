import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:co_run/services/location_service.dart';
import 'package:co_run/services/auth_service.dart';
import 'package:co_run/services/firestore_service.dart';
import 'package:co_run/utils/map_style.dart';
import 'package:co_run/screens/stats/leaderboard_screen.dart';
import 'package:co_run/screens/stats/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<List<Territory>>? _territoriesSubscription;
  Set<Polyline> _territoryPolylines = {};
  bool _isSaving = false;

  // Default fallback (Lahore)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(31.5204, 74.3587),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    // Defer initialization to after build to access context/providers safely if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToTerritories();
      _locateUser();
    });
  }

  void _listenToTerritories() {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser?.uid;

    _territoriesSubscription = firestoreService.territories.listen((territories) {
      if (!mounted) return;
      setState(() {
        _territoryPolylines = territories.map((t) {
          final isMine = t.userId == currentUserId;
          final color = isMine 
              ? const Color(0xFF00FF88).withOpacity(0.6) // Neon Green for me
              : _getUserColor(t.userId).withOpacity(0.4); // Hashed color for others

          return Polyline(
            polylineId: PolylineId(t.id),
            points: t.points,
            color: color,
            width: isMine ? 8 : 6,
            zIndex: isMine ? 2 : 1, // Draw mine on top
            jointType: JointType.round,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
          );
        }).toSet();
      });
    });
  }

  Color _getUserColor(String userId) {
    final hash = userId.hashCode;
    // Generate a consistent color from hash
    return Colors.primaries[hash % Colors.primaries.length];
  }

  Future<void> _locateUser() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    } catch (e) {
      debugPrint('Could not get initial location: $e');
    }
  }

  @override
  void dispose() {
    _territoriesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    // Combine current run polyline with claimed territories
    final allPolylines = {..._territoryPolylines, ...locationService.polylines};

    // Auto-follow user when tracking
    if (locationService.isTracking && locationService.currentLocation != null) {
       _mapController?.animateCamera(
        CameraUpdate.newLatLng(locationService.currentLocation!),
      );
    }

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1E1E1E)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('coRun', style: TextStyle(color: Color(0xFF00FF88), fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('Claim Your City', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard),
              title: const Text('Leaderboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Run History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
              },
            ),
             ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(context);
                await authService.signOut();
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            mapType: MapType.normal, 
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            polylines: allPolylines,
            onMapCreated: (controller) {
              _mapController = controller;
              controller.setMapStyle(darkMapStyle);
            },
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: Color(0xFF00FF88)),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, color: Color(0xFF00FF88), size: 12),
                            const SizedBox(width: 8),
                            Text(
                              authService.currentUser?.email?.split('@')[0] ?? 'Runner',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats Overlay
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: locationService.isTracking 
                            ? const Color(0xFF00FF88) 
                            : Colors.transparent,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('DIST', '${locationService.distanceKm.toStringAsFixed(2)} km'),
                        _buildStat('TIME', locationService.formattedTime),
                        _buildStat('PACE', '${locationService.pace.toStringAsFixed(1)} m/km'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Start/Stop Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isSaving ? null : () => _handleStartStop(context, locationService, authService),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: _isSaving 
                        ? Colors.grey 
                        : (locationService.isTracking ? Colors.red : const Color(0xFF00FF88)),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isSaving 
                            ? Colors.grey 
                            : (locationService.isTracking ? Colors.red : const Color(0xFF00FF88))).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: _isSaving 
                    ? const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.black))
                    : Icon(
                        locationService.isTracking ? Icons.stop : Icons.play_arrow,
                        size: 40,
                        color: Colors.black,
                      ),
                ),
              ),
            ),
          ),
          
          // Current Location Button
          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black87,
              child: const Icon(Icons.my_location, color: Colors.white),
              onPressed: _locateUser,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartStop(BuildContext context, LocationService locationService, AuthService authService) async {
    if (locationService.isTracking) {
      // 1. Capture data BEFORE stopping (or immediately after, since stop doesn't clear)
      locationService.stopTracking();
      
      final distMeters = locationService.distanceMeters;
      final duration = locationService.duration;
      final route = List<LatLng>.from(locationService.routeCoords); // Copy list
      
      // 2. Validate
      if (route.isEmpty || distMeters < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Run too short to save (<10m).')),
        );
        return;
      }

      // 3. Save
      setState(() => _isSaving = true);
      
      try {
        final user = authService.currentUser;
        if (user != null) {
          final firestoreService = Provider.of<FirestoreService>(context, listen: false);
          await firestoreService.saveRun(user.uid, route, distMeters, duration);
          
          if (mounted) {
            _showSummaryDialog(context, distMeters / 1000.0, duration);
          }
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving run: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }

    } else {
      await locationService.startTracking();
    }
  }

  void _showSummaryDialog(BuildContext context, double distKm, Duration duration) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Run Completed!', style: TextStyle(color: Color(0xFF00FF88))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Distance: ${distKm.toStringAsFixed(2)} km', style: const TextStyle(color: Colors.white)),
            Text('Time: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            const Text('Territory Claimed!', style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Awesome', style: TextStyle(color: Color(0xFF00FF88))),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            // Removed custom font family to avoid crashes if not loaded
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
