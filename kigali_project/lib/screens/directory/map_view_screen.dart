import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/listing_provider.dart';
import '../models/listing.dart';
import 'listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();
  final LatLng _initialPosition = const LatLng(-1.9441, 30.0619); // Kigali

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
      appBar: AppBar(
        title: const Text('Map View', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: Consumer<ListingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}', style: const TextStyle(color: Colors.red)));
          }

          final listings = provider.listings;
          
          final markers = listings.map((l) {
            return Marker(
              width: 40.0,
              height: 40.0,
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
                child: Icon(
                  Icons.location_on,
                  color: _getMarkerColor(l.category),
                  size: 40,
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
    );
  }
}
