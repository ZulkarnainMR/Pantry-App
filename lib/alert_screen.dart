// alert_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  // Dapatkan UID user yang login
  String get uid => FirebaseAuth.instance.currentUser!.uid;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Low Stock Alert'),
        backgroundColor: const Color(0xFF2D5A1B),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [

          // --- Ikon Amaran ---
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications,
                    size: 50,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'These items are running low.',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),

          // --- Senarai Item Low Stock ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('pantry_items')
                  .where('status', isEqualTo: 'LOW STOCK')
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Kalau tiada item low stock
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
                        SizedBox(height: 12),
                        Text(
                          'All items are sufficiently stocked!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                List<QueryDocumentSnapshot> items = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                    items[index].data() as Map<String, dynamic>;

                    String itemName = data['itemName'] ?? '-';
                    int quantity = data['quantity'] ?? 0;
                    String unit = data['unit'] ?? '';
                    int minQty = data['minQuantity'] ?? 3;

                    // Tentukan label berdasarkan kuantiti
                    bool outOfStock = quantity == 0;
                    String label = outOfStock ? 'Out of Stock' : 'Restock Soon';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFEBEE),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              _getCategoryImage(data['category'] ?? ''),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Colors.red,
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
                          'Quantity: $quantity $unit\nMin: $minQty $unit',
                        ),
                        isThreeLine: true,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}