import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

class DataSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedInitialData(String systemUserId) async {
    final listingsCollection = _db.collection('listings');
    
    // Check if data already exists to avoid duplicates
    final snapshot = await listingsCollection.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final List<Listing> initialListings = [
      Listing(
        id: '',
        name: 'King Faisal Hospital',
        category: 'Hospital',
        address: 'KG 544 St, Kigali',
        contact: '+250 252 588 888',
        description: 'A leading multi-specialty hospital in Rwanda providing advanced medical services.',
        lat: -1.9447,
        lng: 30.0934,
        createdBy: systemUserId,
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '',
        name: 'CHUK (University Teaching Hospital of Kigali)',
        category: 'Hospital',
        address: 'KN 4 Ave, Kigali',
        contact: '+250 252 575 405',
        description: 'The largest public hospital in Rwanda, providing tertiary care and medical education.',
        lat: -1.9441,
        lng: 30.0619,
        createdBy: systemUserId,
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '',
        name: 'Heaven Restaurant',
        category: 'Restaurant',
        address: 'KN 29 St, Kigali',
        contact: '+250 788 486 335',
        description: 'Famous for its beautiful garden setting and delicious innovative African cuisine.',
        lat: -1.9496,
        lng: 30.0624,
        createdBy: systemUserId,
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '',
        name: 'Repub Lounge',
        category: 'Restaurant',
        address: 'KG 674 St, Kigali',
        contact: '+250 788 303 030',
        description: 'Popular spot offering great views of the city and authentic Rwandan grilled specialties.',
        lat: -1.9542,
        lng: 30.0911,
        createdBy: systemUserId,
        timestamp: DateTime.now(),
      ),
    ];

    for (var listing in initialListings) {
      await listingsCollection.add(listing.toMap());
    }
    
    print('Initial data seeded successfully!');
  }
}
