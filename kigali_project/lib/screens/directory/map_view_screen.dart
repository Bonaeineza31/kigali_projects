import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/listing.dart';
import 'listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();
  final LatLng _initialPosition = const LatLng(-1.9441, 30.0619); // Kigali

  bool _showAllListings = true;

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase().trim();
    if (cat.contains('hospital')) return Icons.local_hospital;
    if (cat.contains('restaurant')) return Icons.restaurant;
    if (cat.contains('garage')) return Icons.build;
    if (cat.contains('café') || cat.contains('cafe')) return Icons.coffee;
    if (cat.contains('park')) return Icons.park;
    if (cat.contains('police')) return Icons.local_police;
    if (cat.contains('library')) return Icons.local_library;
    if (cat.contains('tourist') || cat.contains('attraction')) return Icons.attractions;
    if (cat.contains('utility') || cat.contains('office')) return Icons.business;
    return Icons.location_on;
  }

  Color _getMarkerColor(String category) {
    final cat = category.toLowerCase().trim();
    if (cat.contains('hospital')) return Colors.red;
    if (cat.contains('restaurant')) return Colors.orange;
    if (cat.contains('garage')) return Colors.deepPurple;
    if (cat.contains('café') || cat.contains('cafe')) return Colors.brown;
    if (cat.contains('park')) return Colors.green;
    if (cat.contains('police')) return Colors.blue;
    if (cat.contains('tourist')) return Colors.teal;
    if (cat.contains('utility')) return Colors.blueGrey;
    return const Color(0xFF1E3A8A);
  }

  void _fitMapToMarkers(List<Listing> listings) {
    if (listings.isEmpty || !mounted) return;
    
    try {
      final points = listings.map((l) => LatLng(l.lat, l.lng)).toList();
      final bounds = LatLngBounds.fromPoints(points);
      
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(70),
          maxZoom: 15,
        ),
      );
    } catch (e) {
      debugPrint('Error fitting map to markers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.user?.uid ?? '';

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

              final allListings = provider.allListings;
              final myListings = allListings.where((l) => l.createdBy == uid).toList();
              final listings = _showAllListings ? allListings : myListings;
              
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
                  onMapReady: () {
                    if (listings.isNotEmpty) {
                      _fitMapToMarkers(listings);
                    }
                  }
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
          // Map Toggle & Zoom Controls
          Positioned(
            left: 16,
            bottom: 32,
            child: Column(
              children: [
                _ZoomButton(
                  tooltip: _showAllListings ? 'Show My Listings' : 'Show All Listings',
                  icon: _showAllListings ? Icons.group : Icons.person,
                  onPressed: () {
                    setState(() {
                      _showAllListings = !_showAllListings;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _ZoomButton(
                  tooltip: 'Center on Listings',
                  icon: Icons.filter_center_focus,
                  onPressed: () {
                    final provider = Provider.of<ListingProvider>(context, listen: false);
                    final listings = _showAllListings 
                      ? provider.allListings 
                      : provider.allListings.where((l) => l.createdBy == uid).toList();
                    _fitMapToMarkers(listings);
                  },
                ),
                const SizedBox(height: 12),
                _ZoomButton(
                  tooltip: 'Zoom In',
                  icon: Icons.add,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom + 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                ),
                const SizedBox(height: 12),
                _ZoomButton(
                  tooltip: 'Zoom Out',
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
  final String tooltip;

  const _ZoomButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

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
        tooltip: tooltip,
        icon: Icon(icon, color: const Color(0xFF1E3A8A)),
        onPressed: onPressed,
      ),
    );
  }
}
