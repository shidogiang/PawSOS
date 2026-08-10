import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  final String reporterName;

  const CallScreen({super.key, required this.reporterName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), 
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade100,
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 30, spreadRadius: 10)
                ],
              ),
              child: const Icon(Icons.person, color: Colors.blue, size: 60),
            ),
            const SizedBox(height: 24),
            
            Text(reporterName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Đang đổ chuông...', style: TextStyle(color: Colors.grey, fontSize: 16)),
            
            const Spacer(),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCallBtn(Icons.mic_off, 'Tắt âm', Colors.white24, Colors.white),
                  _buildCallBtn(Icons.volume_up, 'Loa ngoài', Colors.white24, Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 70, height: 70,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.call_end, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCallBtn(IconData icon, String label, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}