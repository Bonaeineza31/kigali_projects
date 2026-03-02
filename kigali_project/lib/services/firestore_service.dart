import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';
import '../models/app_user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Profile ---
  
  Future<AppUser?> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data() as Map<String, dynamic>, uid);
    }
    return null;
  }

  // --- Listings CRUD ---

  // Create
  Future<void> createListing(Listing listing) async {
    await _db.collection('listings').add(listing.toMap());
  }

  // Read all
  Stream<List<Listing>> streamListings() {
    return _db
        .collection('listings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  // Read user listings
  Stream<List<Listing>> streamUserListings(String uid) {
    return _db
        .collection('listings')
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  // Update
  Future<void> updateListing(Listing listing) async {
    await _db.collection('listings').doc(listing.id).update(listing.toMap());
  }

  // Delete
  Future<void> deleteListing(String id) async {
    await _db.collection('listings').doc(id).delete();
  }
}
