import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:co_run/services/location_service.dart';
import 'package:co_run/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  
  // Example initial position (Lahore)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(31.5204, 74.3587),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            mapType: MapType.dark, // Dark mode map
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            polylines: locationService.polylines,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          
          // Stats Overlay
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('DIST', '${locationService.distance.toStringAsFixed(2)} km'),
                  _buildStat('TIME', locationService.formattedTime),
                  _buildStat('PACE', '${locationService.pace.toStringAsFixed(1)} m/km'),
                ],
              ),
            ),
          ),

          // Start/Stop Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (locationService.isTracking) {
                    locationService.stopTracking();
                  } else {
                    locationService.startTracking();
                  }
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: locationService.isTracking ? Colors.red : Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (locationService.isTracking ? Colors.red : Theme.of(context).primaryColor).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    locationService.isTracking ? Icons.stop : Icons.play_arrow,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          
          // Sign Out Button (Top Right)
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                 await authService.signOut();
              },
            ),
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
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
