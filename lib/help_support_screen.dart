// help_support_screen.dart
import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Warna background sepadan dengan sistem
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF2D5A1B), // Hijau tema
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION: CONTACT US ---
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A1B),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFFDCEDC8),
                        child: Icon(Icons.email_outlined, color: Color(0xFF2D5A1B)),
                      ),
                      title: Text('Email Support', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('support@pantrytracker.com'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    Divider(color: Colors.grey.shade200),
                    const ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFFDCEDC8),
                        child: Icon(Icons.phone_outlined, color: Color(0xFF2D5A1B)),
                      ),
                      title: Text('WhatsApp / Call', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('+60 14-6299548'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // --- SECTION: FAQ ---
            const Text(
              'Frequently Asked Questions (FAQ)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A1B),
              ),
            ),
            const SizedBox(height: 10),
            
            _buildFAQItem(
              question: 'How to add a new item?',
              answer: 'Go to the "Add" tab at the bottom navigation bar. Fill in the item details like name, quantity, category, and expiry date, then tap "Save Item".',
            ),
            _buildFAQItem(
              question: 'How do I get low stock alerts?',
              answer: 'When adding an item, you set a "Min Quantity". If the item\'s current quantity falls below this number, its status will automatically be marked as "Low Stock".',
            ),
            _buildFAQItem(
              question: 'How to delete an item?',
              answer: 'Go to the "Add" tab where your registered items are listed. Scroll down and tap the red trash bin icon next to the item you want to remove.',
            ),
            _buildFAQItem(
              question: 'Can I change my profile picture?',
              answer: 'Yes! Go to the "Profile" tab and tap the small camera icon on your avatar to upload a new picture directly from your phone gallery.',
            ),

          ],
        ),
      ),
    );
  }

  // Fungsi bina komponen FAQ (Boleh Kembang/Kecut)
  Widget _buildFAQItem({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: Colors.white,
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        iconColor: const Color(0xFF2D5A1B),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(color: Colors.black87, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
