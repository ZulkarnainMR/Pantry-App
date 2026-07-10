// item_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

class ItemDetailScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const ItemDetailScreen({super.key, required this.docId, required this.data});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {


  // Fungsi untuk sambungkan nama kategori dengan fail gambar
  String _getCategoryImage(String category) {
    switch (category) {
      case 'Grains':
        return 'assets/grains.webp';
      case 'Canned Goods':
        return 'assets/canned goods.webp';
      case 'Beverages':
        return 'assets/beverages.webp';
      case 'Snacks':
        return 'assets/snacks.webp';
      case 'Condiments':
        return 'assets/condiments.webp';
      case 'Dairy':
        return 'assets/dairy.webp';
      default:
        return 'assets/pantry(1).webp'; // Gambar asas jika tiada dalam senarai
    }
  }
  // Controller untuk form edit
  late TextEditingController _nameController;
  late TextEditingController _qtyController;
  late TextEditingController _minQtyController;
  late String _selectedCategory;
  late String _selectedUnit;
  late DateTime _selectedDate;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  final List<String> _categories = [
    'Grains', 'Canned Goods', 'Beverages',
    'Snacks', 'Condiments', 'Dairy', 'Other'
  ];
  final List<String> _units = ['kg', 'g', 'L', 'mL', 'pcs', 'pk', 'tin', 'box'];

  @override
  void initState() {
    super.initState();

    // Isi nilai asal dari data yang dihantar
    _nameController = TextEditingController(text: widget.data['itemName'] ?? '');
    _qtyController = TextEditingController(text: (widget.data['quantity'] ?? 0).toString());
    _minQtyController = TextEditingController(text: (widget.data['minQuantity'] ?? 3).toString());
    _selectedCategory = widget.data['category'] ?? 'Grains';
    _selectedUnit = widget.data['unit'] ?? 'kg';
    _selectedDate = (widget.data['expiryDate'] as Timestamp).toDate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _minQtyController.dispose();
    super.dispose();
  }

  // Fungsi format tarikh
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // --- LETAK DI SINI ---

  // Fungsi pilih tarikh
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi UPDATE item
  void _updateItem() async {
    if (_nameController.text.isEmpty || _qtyController.text.isEmpty) {
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

    // Semak status: LOW STOCK atau OK
    String status = qty <= minQty ? 'LOW STOCK' : 'OK';

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('pantry_items')
          .doc(widget.docId)
          .update({
        'itemName': _nameController.text.trim(),
        'category': _selectedCategory,
        'quantity': qty,
        'unit': _selectedUnit,
        'expiryDate': Timestamp.fromDate(_selectedDate),
        'minQuantity': minQty,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated!'), backgroundColor: Colors.green),
      );

      // Trigger notification if low stock
      if (status == 'LOW STOCK') {
        NotificationService().showLowStockNotification(_nameController.text.trim(), remainingQty: qty);
      }

      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Fungsi DELETE item dengan dialog pengesahan
  void _deleteItem() {
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
                  .doc(widget.docId)
                  .delete();

              if (!mounted) return;
              Navigator.pop(context); // tutup dialog
              Navigator.pop(context); // balik ke Home
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Item Detail'),
        backgroundColor: const Color(0xFF2D5A1B),
        foregroundColor: Colors.white,
        actions: [
          // Butang delete di AppBar
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Item Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A1B),
              ),
            ),
            const SizedBox(height: 20),

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
            const Text('Min Quantity (Low Stock Threshold)', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    Text(_formatDate(_selectedDate)),
                    const Icon(Icons.calendar_today_outlined, color: Color(0xFF4A7C2F)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Butang Update ---
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
                onPressed: _updateItem,
                child: const Text(
                  'Update Item',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}