import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/listing.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  List<LatLng> _routePoints = [];
  final MapController _mapController = MapController();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getAndShowRoute();
  }

  Future<void> _getAndShowRoute() async {
    try {
      // 1. Verify Location Services & Permissions (Essential to prevent crashes)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      // 2. Get current position
      _currentPosition = await Geolocator.getCurrentPosition();
      
      // 3. Fetch OSRM route
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${_currentPosition!.longitude},${_currentPosition!.latitude};'
        '${widget.listing.lng},${widget.listing.lat}'
        '?overview=full&geometries=geojson'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];
        
        if (mounted) {
          setState(() {
            _routePoints = coordinates.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
          });
        }

        // 4. Update map to show both markers
        if (_routePoints.isNotEmpty && mounted) {
           _mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints([
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                LatLng(widget.listing.lat, widget.listing.lng),
              ]),
              padding: const EdgeInsets.all(50),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
  }

  Future<void> _launchNavigation(BuildContext context) async {
    try {
      // Fetch fresh position right before launching to ensure sync with emulator location
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
              background: FlutterMap(
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
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: const Color(0xFF1E3A8A),
                          strokeWidth: 5,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      // Listing Marker
                      Marker(
                        width: 50.0,
                        height: 50.0,
                        point: LatLng(widget.listing.lat, widget.listing.lng),
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF1E3A8A),
                          size: 50,
                        ),
                      ),
                      // Current Location Marker
                      if (_currentPosition != null)
                        Marker(
                          width: 40.0,
                          height: 40.0,
                          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                    ],
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
