import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/listing.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;

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

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchNavigation(BuildContext context) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));

      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=${widget.listing.lat},${widget.listing.lng}&travelmode=driving'
      );

      final launched = await launchUrl(
        googleMapsUrl, 
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        throw 'Maps app not available.';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(widget.listing.lat, widget.listing.lng),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.kigali_project',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 60.0,
                            height: 60.0,
                            point: LatLng(widget.listing.lat, widget.listing.lng),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                _getCategoryIcon(widget.listing.category),
                                color: const Color(0xFF1E3A8A),
                                size: 35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Zoom Controls
                  Positioned(
                    right: 16,
                    bottom: 16,
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
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.listing.category.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.listing.name,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _InfoTile(icon: Icons.location_on_outlined, text: widget.listing.address),
                  const SizedBox(height: 12),
                  _InfoTile(icon: Icons.phone_outlined, text: widget.listing.contact),
                  const SizedBox(height: 32),
                  const Text(
                    'About this place',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.listing.description,
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchNavigation(context),
                      icon: const Icon(Icons.navigation_outlined),
                      label: const Text('GET DIRECTIONS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: const Color(0xFF1E3A8A).withOpacity(0.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3B82F6), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
