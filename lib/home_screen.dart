// home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'item_detail_screen.dart';
import 'notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Controller untuk search bar
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // Dapatkan UID user yang sedang login
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // Fungsi format tarikh jadi string
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getCategoryImage(String category) {
    switch (category) {
      case 'Grains': return 'assets/grains.webp';
      case 'Canned Goods': return 'assets/canned goods.webp';
      case 'Beverages': return 'assets/beverages.webp';
      case 'Snacks': return 'assets/snacks.webp';
      case 'Condiments': return 'assets/condiments.webp';
      case 'Dairy': return 'assets/dairy.webp';
      default: return 'assets/pantry(1).webp';
    }
  }

  @override
  void initState() {
    super.initState();
    // Request notification permission for Android 13+
    try {
      NotificationService().requestPermission();
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [

            // ============ HEADER ============
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF2D5A1B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Tunjuk nama pengguna dari Firestore
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .get(),
                    builder: (context, snapshot) {
                      String name = 'User';
                      if (snapshot.hasData && snapshot.data!.exists) {
                        name = snapshot.data!['name'] ?? 'User';
                      }
                      return Text(
                        'Hello, $name',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const Text(
                    "Here's your pantry overview",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Senarai Barang
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('pantry_items')
                        .snapshots(),
                    builder: (context, snapshot) {
                      int totalItems = 0;
                      int lowStock = 0;

                      if (snapshot.hasData) {
                        totalItems = snapshot.data!.docs.length;
                        for (var doc in snapshot.data!.docs) {
                          Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                          if (data['status'] == 'LOW STOCK') {
                            lowStock++;
                          }
                        }
                      }

                      return Row(
                        children: [

                          // Card: Total Items
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Items',
                                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text(
                                    '$totalItems',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Card: Low Stock
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Low Stock',
                                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  Row(
                                    children: [
                                      Text(
                                        '$lowStock',
                                        style: const TextStyle(
                                          color: Color(0xFFE53935),
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.warning_amber_rounded,
                                          color: Color(0xFFE53935), size: 22),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // ============ SEARCH BAR ============
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search pantry items...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF4A7C2F)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // ============ TAJUK SENARAI ============
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Pantry Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A1B),
                  ),
                ),
              ),
            ),

            //   SENARAI ITEM
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('pantry_items')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No items yet. Tap Add to start!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  // Filter berdasarkan carian
                  List<QueryDocumentSnapshot> items =
                  snapshot.data!.docs.where((doc) {
                    String name =
                    (doc['itemName'] ?? '').toString().toLowerCase();
                    return name.contains(_searchText);
                  }).toList();

                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No items found.', style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      var doc = items[index];
                      Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;

                      String itemName = data['itemName'] ?? '-';
                      int quantity = data['quantity'] ?? 0;
                      String unit = data['unit'] ?? '';
                      String status = data['status'] ?? 'OK';
                      DateTime expiryDate =
                      (data['expiryDate'] as Timestamp).toDate();
                      bool isLow = status == 'LOW STOCK';

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFDCEDC8),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                _getCategoryImage(data['category'] ?? ''),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.inventory_2_outlined,
                                    color: Color(0xFF2D5A1B),
                                  );
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            itemName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Quantity: $quantity $unit\nExpiry: ${_formatDate(expiryDate)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isLow
                                  ? const Color(0xFFFFEBEE)
                                  : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isLow ? 'Low' : 'OK',
                              style: TextStyle(
                                color: isLow ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          // Klik item untuk buka halaman detail
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ItemDetailScreen(
                                  docId: doc.id,
                                  data: data,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}