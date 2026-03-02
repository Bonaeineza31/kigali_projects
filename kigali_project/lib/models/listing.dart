import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contact;
  final String description;
  final double lat;
  final double lng;
  final String createdBy;
  final DateTime timestamp;

  Listing({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contact,
    required this.description,
    required this.lat,
    required this.lng,
    required this.createdBy,
    required this.timestamp,
  });

  factory Listing.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Listing(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      contact: data['contact'] ?? '',
      description: data['description'] ?? '',
      lat: (data['lat'] ?? 0.0).toDouble(),
      lng: (data['lng'] ?? 0.0).toDouble(),
      createdBy: data['createdBy'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contact': contact,
      'description': description,
      'lat': lat,
      'lng': lng,
      'createdBy': createdBy,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
