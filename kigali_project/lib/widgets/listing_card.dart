import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing.dart';
import '../providers/listing_provider.dart';
import '../screens/directory/listing_detail_screen.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ListingCard({
    super.key,
    required this.listing,
    this.onDelete,
    this.onEdit,
  });

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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Hospital': return Colors.red;
      case 'Restaurant': return Colors.orange;
      case 'Garage': return Colors.blueGrey;
      case 'Café': return Colors.brown;
      case 'Park': return Colors.green;
      case 'Police Station': return Colors.blue;
      case 'Library': return Colors.blueGrey;
      default: return const Color(0xFF1E3A8A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ListingProvider>(context);
    final isBookmarked = provider.isBookmarked(listing.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListingDetailScreen(listing: listing),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(listing.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      _getCategoryIcon(listing.category),
                      color: _getCategoryColor(listing.category),
                      size: 35,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              listing.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getCategoryColor(listing.category),
                                letterSpacing: 1.2,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: isBookmarked ? const Color(0xFF1E3A8A) : Colors.grey,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => provider.toggleBookmark(listing.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          listing.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                listing.address,
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (onEdit != null || onDelete != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey[100]!)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onEdit != null)
                          TextButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                            style: TextButton.styleFrom(foregroundColor: Colors.blue),
                          ),
                        if (onDelete != null)
                          TextButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Delete'),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
