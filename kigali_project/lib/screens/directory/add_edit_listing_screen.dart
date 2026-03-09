import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';

class AddEditListingScreen extends StatefulWidget {
  final Listing? listing;

  const AddEditListingScreen({super.key, this.listing});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  
  String _selectedCategory = 'Restaurant';
  final List<String> _categories = [
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Garage',
    'Café',
    'Park',
    'Tourist Attraction',
    'Utility Office'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.listing != null) {
      _nameController.text = widget.listing!.name;
      _addressController.text = widget.listing!.address;
      _contactController.text = widget.listing!.contact;
      _descriptionController.text = widget.listing!.description;
      _latController.text = widget.listing!.lat.toString();
      _lngController.text = widget.listing!.lng.toString();
      _selectedCategory = widget.listing!.category;
    } else {
      // Default to Kigali city center coordinates
      _latController.text = "-1.9441";
      _lngController.text = "30.0619";
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Base color to prevent flickering
      body: Stack(
        children: [
          // 1. Background Image Header
          Container(
            height: 320,
            width: double.infinity,
            child: Image.asset(
              'assets/images/kigali_convention_night.png',
              fit: BoxFit.cover,
            ),
          ),
          // 2. Sophisticated Dark Gradient Overlay
          Container(
            height: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          // 3. Scrollable Form Card
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 220), // Spacing for the header image
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStyledField(
                            controller: _nameController,
                            label: 'Place or Service Name',
                            icon: Icons.business_rounded,
                            validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildCategoryDropdown(),
                          const SizedBox(height: 20),
                          _buildStyledField(
                            controller: _addressController,
                            label: 'Street Address',
                            icon: Icons.location_on_rounded,
                            validator: (value) => value == null || value.isEmpty ? 'Please enter an address' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildStyledField(
                            controller: _contactController,
                            label: 'Contact Phone',
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                            validator: (value) => value == null || value.isEmpty ? 'Please enter contact info' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildStyledField(
                            controller: _descriptionController,
                            label: 'About this Place',
                            icon: Icons.notes_rounded,
                            maxLines: 4,
                            validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStyledField(
                                  controller: _latController,
                                  label: 'Latitude',
                                  icon: Icons.gps_fixed_rounded,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStyledField(
                                  controller: _lngController,
                                  label: 'Longitude',
                                  icon: Icons.gps_fixed_rounded,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final newListing = Listing(
                                  id: widget.listing?.id ?? '',
                                  name: _nameController.text,
                                  category: _selectedCategory,
                                  address: _addressController.text,
                                  contact: _contactController.text,
                                  description: _descriptionController.text,
                                  lat: double.parse(_latController.text),
                                  lng: double.parse(_lngController.text),
                                  createdBy: widget.listing?.createdBy ?? authProvider.user!.uid,
                                  timestamp: widget.listing?.timestamp ?? DateTime.now(),
                                );

                                if (widget.listing == null) {
                                  await listingProvider.addListing(newListing);
                                } else {
                                  await listingProvider.updateListing(newListing);
                                }

                                if (mounted) Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                              shadowColor: const Color(0xFF1E3A8A).withOpacity(0.3),
                            ),
                            child: Text(
                              widget.listing == null ? 'Create Listing' : 'Save Changes',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 4. Floating AppBar Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.listing == null ? 'Add New Listing' : 'Edit Listing',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A).withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'Category',
          labelStyle: TextStyle(color: Colors.blueGrey.withOpacity(0.6)),
          prefixIcon: Icon(Icons.category_outlined, color: const Color(0xFF1E3A8A).withOpacity(0.7)),
          border: InputBorder.none,
        ),
        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (value) => setState(() => _selectedCategory = value!),
      ),
    );
  }
}
