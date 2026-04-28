import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/business_provider.dart';

class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sistem Antrean Digital')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nomor Antrean Saat Ini', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                provider.currentServing == 0 ? '-' : provider.currentServing.toString().padLeft(3, '0'),
                style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQueueAction(
                  context, 
                  'Ambil Tiket', 
                  Icons.confirmation_num, 
                  () => provider.issueTicket(),
                  'Tiket Terakhir: ${provider.lastTicket}',
                ),
                const SizedBox(width: 24),
                _buildQueueAction(
                  context, 
                  'Panggil Berikutnya', 
                  Icons.campaign, 
                  () => provider.callNext(),
                  'Petugas Only',
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueAction(BuildContext context, String label, IconData icon, VoidCallback onPressed, String subtext, {bool isPrimary = false}) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(24),
            backgroundColor: isPrimary ? Theme.of(context).colorScheme.primary : null,
            foregroundColor: isPrimary ? Theme.of(context).colorScheme.onPrimary : null,
          ),
          onPressed: onPressed,
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(subtext, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
