import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import 'listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();
  final LatLng _initialPosition = const LatLng(-1.9441, 30.0619); // Kigali

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hospital': return Icons.local_hospital;
      case 'Restaurant': return Icons.restaurant;
      case 'Garage': return Icons.build;
      case 'Café': return Icons.coffee;
      case 'Park': return Icons.park;
      case 'Police Station': return Icons.local_police;
      case 'Library': return Icons.local_library;
      default: return Icons.location_on;
    }
  }

  Color _getMarkerColor(String category) {
    switch (category) {
      case 'Hospital': return Colors.red;
      case 'Restaurant': return Colors.orange;
      case 'Garage': return Colors.deepPurple;
      case 'Café': return Colors.brown;
      case 'Park': return Colors.green;
      case 'Police Station': return Colors.blue;
      default: return const Color(0xFF1E3A8A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<ListingProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.errorMessage != null) {
                return Center(
                  child: Text(
                    'Error: ${provider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final listings = provider.listings;
              
              final markers = listings.map((l) {
                return Marker(
                  width: 50.0,
                  height: 50.0,
                  point: LatLng(l.lat, l.lng),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListingDetailScreen(listing: l),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        _getCategoryIcon(l.category),
                        color: _getMarkerColor(l.category),
                        size: 28,
                      ),
                    ),
                  ),
                );
              }).toList();

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialPosition,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.kigali_project',
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
          ),
          // Zoom Controls
          Positioned(
            right: 16,
            bottom: 32,
            child: Column(
              children: [
                _ZoomButton(
                  icon: Icons.add,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom + 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                ),
                const SizedBox(height: 12),
                _ZoomButton(
                  icon: Icons.remove,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom - 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                ),
              ],
            ),
          ),
          // Floated Header with No Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1E3A8A).withOpacity(0.9),
                    const Color(0xFF1E3A8A).withOpacity(0.0),
                  ],
                ),
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text(
                    'Map View',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ZoomButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF1E3A8A)),
        onPressed: onPressed,
      ),
    );
  }
}
