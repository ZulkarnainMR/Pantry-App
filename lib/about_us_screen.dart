import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color(0xFF2D5A1B),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Logo App
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFDCEDC8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.kitchen, size: 60, color: Color(0xFF2D5A1B)),
            ),
            const SizedBox(height: 16),
            const Text(
              'PANTRY TRACKER',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A1B),
                letterSpacing: 1.5,
              ),
            ),
            const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // Penerangan App
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About This App',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D5A1B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pantry Tracker is a mobile application designed to help '
                      'users manage stored household items. Users can add pantry '
                      'items, track quantity, monitor expiry dates, and receive '
                      'notifications when stock becomes low. The app uses Firebase '
                      'for secure authentication and real-time data storage.',
                      style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Maklumat Developer
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D5A1B),
                      ),
                    ),
                    SizedBox(height: 8),
                    _DevInfoRow(label: 'Name', value: 'Muhammad Zulkarnain bin Mohd Rozi'),
                    _DevInfoRow(label: 'Student ID', value: '079963'),
                    _DevInfoRow(label: 'Program', value: 'Diploma in Sains Komputer'),
                    _DevInfoRow(label: 'Course', value: 'ITD20304 - Mobile App Dev'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DevInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
