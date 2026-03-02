import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/firestore_service.dart';
import '../services/data_seeder.dart';
import 'dart:async';

class ListingProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Listing> _allListings = [];
  final Set<String> _bookmarkedIds = {};
  String _searchQuery = '';
  String _selectedCategory = 'All';
  StreamSubscription? _listingsSubscription;
  bool _isLoading = true;
  String? _errorMessage;

  ListingProvider() {
    _startListingSubscription();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _startListingSubscription() {
    _listingsSubscription?.cancel();
    _listingsSubscription = _firestoreService.streamListings().listen(
      (listings) {
        _allListings = listings;
        _isLoading = false;
        _errorMessage = null;
        
        // Seed data if empty (using a generic ID or first found user ID)
        if (_allListings.isEmpty) {
          // Note: In a real app, you'd pass the actual UID, 
          // but for seeding static data we just need a creator ID.
          DataSeeder.seedInitialData('system_admin');
        }
        
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
        print('Firestore Stream Error: $error');
      },
    );
  }

  List<Listing> get listings {
    List<Listing> filtered = _allListings;
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((l) => l.category == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((l) => 
        l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        l.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  List<Listing> get bookmarkedListings {
    return _allListings.where((l) => _bookmarkedIds.contains(l.id)).toList();
  }

  String get selectedCategory => _selectedCategory;

  bool isBookmarked(String id) => _bookmarkedIds.contains(id);

  void toggleBookmark(String id) {
    if (_bookmarkedIds.contains(id)) {
      _bookmarkedIds.remove(id);
    } else {
      _bookmarkedIds.add(id);
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // CRUD Actions
  Future<void> addListing(Listing listing) async {
    await _firestoreService.createListing(listing);
  }

  Future<void> updateListing(Listing listing) async {
    await _firestoreService.updateListing(listing);
  }

  Future<void> deleteListing(String id) async {
    await _firestoreService.deleteListing(id);
  }

  // Stream for user specific listings
  Stream<List<Listing>> userListingsStream(String uid) => _firestoreService.streamUserListings(uid);

  @override
  void dispose() {
    _listingsSubscription?.cancel();
    super.dispose();
  }
}
