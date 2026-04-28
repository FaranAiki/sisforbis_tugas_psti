import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/business_provider.dart';

class CRMPage extends StatelessWidget {
  const CRMPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Relationship Management')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daftar Pelanggan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2,
                ),
                itemCount: provider.customers.length,
                itemBuilder: (context, index) {
                  final customer = provider.customers[index];
                  return Card(
                    child: ListTile(
                      title: Text(customer['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(customer['email']),
                      onTap: () => _showCustomerDetails(context, customer),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomerDialog(context),
        label: const Text('Pelanggan Baru'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          String? nameError;
          if (nameController.text.isNotEmpty && nameController.text.trim().isEmpty) {
            nameError = 'Nama tidak boleh hanya spasi';
          }

          String? emailError;
          final email = emailController.text.trim().toLowerCase();
          if (emailController.text.isNotEmpty && !email.endsWith('@gmail.com')) {
            emailError = 'Email harus menggunakan domain @gmail.com';
          }

          String? phoneError;
          if (phoneController.text.isNotEmpty && phoneController.text.trim().isEmpty) {
            phoneError = 'Nomor telepon tidak boleh kosong';
          }

          bool isValid = nameController.text.trim().isNotEmpty && 
                         email.endsWith('@gmail.com') && 
                         phoneController.text.trim().isNotEmpty;

          return AlertDialog(
            title: const Text('Tambah Pelanggan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController, 
                  decoration: InputDecoration(labelText: 'Nama', errorText: nameError),
                  onChanged: (_) => setState(() {}),
                ),
                TextField(
                  controller: emailController, 
                  decoration: InputDecoration(labelText: 'Email', errorText: emailError),
                  onChanged: (_) => setState(() {}),
                ),
                TextField(
                  controller: phoneController, 
                  decoration: InputDecoration(labelText: 'Telepon', errorText: phoneError),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
              ElevatedButton(
                onPressed: isValid ? () {
                  context.read<BusinessProvider>().addCustomer(
                    nameController.text.trim(), 
                    email, 
                    phoneController.text.trim()
                  );
                  Navigator.pop(context);
                } : null,
                child: const Text('Simpan'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, Map<String, dynamic> customer) async {
    final interactions = await context.read<BusinessProvider>().getInteractions(customer['id']);
    
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(customer['email'], style: const TextStyle(color: Colors.grey)),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Riwayat Interaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Catatan'),
                    onPressed: () => _showAddInteractionDialog(context, customer['id']),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: interactions.length,
                  itemBuilder: (context, index) {
                    final note = interactions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(note['note']),
                        subtitle: Text(DateFormat.yMMMd().format(DateTime.parse(note['date']))),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (i) => Icon(Icons.star, size: 16, color: i < (note['rating'] ?? 0) ? Colors.orange : Colors.grey[300])),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddInteractionDialog(BuildContext context, int customerId) {
    final noteController = TextEditingController();
    int rating = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Interaksi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Catatan')),
              const SizedBox(height: 16),
              const Text('Rating Layanan:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(Icons.star, color: index < rating ? Colors.orange : Colors.grey),
                  onPressed: () => setState(() => rating = index + 1),
                )),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                context.read<BusinessProvider>().addInteraction(customerId, noteController.text, rating);
                Navigator.pop(context);
                Navigator.pop(context); // Close bottom sheet
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
