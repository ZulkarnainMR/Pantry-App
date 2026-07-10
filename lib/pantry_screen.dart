// pantry_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {

  // Controller untuk form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _minQtyController = TextEditingController();

  // Nilai dropdown dan tarikh
  String _selectedCategory = 'Grains';
  String _selectedUnit = 'kg';
  DateTime? _selectedDate;
  bool _isLoading = false;

  // Senarai pilihan
  final List<String> _categories = [
    'Grains', 'Canned Goods', 'Beverages',
    'Snacks', 'Condiments', 'Dairy', 'Other'
  ];
  final List<String> _units = ['kg', 'g', 'L', 'mL', 'pcs', 'pk', 'tin', 'box'];

  // Dapatkan UID user yang login
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // Format tarikh jadi string
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Buka date picker
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi TAMBAH item ke Firestore
  void _addItem() async {

    // Validasi semua field diisi
    if (_nameController.text.isEmpty ||
        _qtyController.text.isEmpty ||
        _minQtyController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    int qty = int.tryParse(_qtyController.text) ?? 0;
    int minQty = int.tryParse(_minQtyController.text) ?? 3;

    // Tentukan status berdasarkan kuantiti
    String status = qty <= minQty ? 'LOW STOCK' : 'OK';

    setState(() { _isLoading = true; });

    try {
      // Simpan item ke Firestore di bawah user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('pantry_items')
          .add({
        'itemName': _nameController.text.trim(),
        'category': _selectedCategory,
        'quantity': qty,
        'unit': _selectedUnit,
        'expiryDate': Timestamp.fromDate(_selectedDate!),
        'minQuantity': minQty,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Trigger notification if low stock
      if (status == 'LOW STOCK') {
        NotificationService().showLowStockNotification(_nameController.text.trim(), remainingQty: qty);
      }

      // Kosongkan form
      _nameController.clear();
      _qtyController.clear();
      _minQtyController.clear();
      setState(() {
        _selectedCategory = 'Grains';
        _selectedUnit = 'kg';
        _selectedDate = null;
      });

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  // Fungsi DELETE item
  void _deleteItem(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('pantry_items')
                  .doc(docId)
                  .delete();
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item deleted!'), backgroundColor: Colors.orange),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _minQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Add New Item'),
        backgroundColor: const Color(0xFF2D5A1B),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Ikon atas (GAMBAR DINAMIK)
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    _getCategoryImage(_selectedCategory), // Panggil fungsi di atas
                    fit: BoxFit.cover,
                    // Jika fail gambar tiada, tunjuk ikon bakul asal
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.shopping_basket_outlined,
                        size: 50,
                        color: Color(0xFF4A7C2F),
                      );
                    },
                  ),
                ),
              ),
            ),
            // ============ FORM ============

            // --- Item Name ---
            const Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Rice',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Quantity + Unit ---
            const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 2',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedUnit,
                        onChanged: (val) => setState(() { _selectedUnit = val!; }),
                        items: _units
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Min Quantity ---
            const Text('Min Quantity (Low Stock Alert)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _minQtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 3',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Category ---
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  onChanged: (val) => setState(() { _selectedCategory = val!; }),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Expiry Date ---
            const Text('Expiry Date', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Select date'
                          : _formatDate(_selectedDate!),
                      style: TextStyle(
                        color: _selectedDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined, color: Color(0xFF4A7C2F)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Butang Save ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A1B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _addItem,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Save Item',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ============ SENARAI ITEM ============
            const Text(
              'Registered Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A1B),
              ),
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
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
                    child: Text('No items added yet.', style: TextStyle(color: Colors.grey)),
                  );
                }

                List<QueryDocumentSnapshot> items = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var doc = items[index];
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                    String itemName = data['itemName'] ?? '-';
                    int quantity = data['quantity'] ?? 0;
                    String unit = data['unit'] ?? '';
                    String category = data['category'] ?? '';
                    String status = data['status'] ?? 'OK';
                    bool isLow = status == 'LOW STOCK';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFDCEDC8),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              _getCategoryImage(category),
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
                        subtitle: Text('$quantity $unit · $category'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Badge status
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isLow
                                    ? const Color(0xFFFFEBEE)
                                    : const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isLow ? 'Low' : 'OK',
                                style: TextStyle(
                                  color: isLow ? Colors.red : Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Butang delete
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteItem(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}