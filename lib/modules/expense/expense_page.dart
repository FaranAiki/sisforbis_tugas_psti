import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/business_provider.dart';
import '../../core/widgets/calc_text_field.dart';

class ExpensePage extends StatelessWidget {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Biaya Operasional')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Riwayat Pengeluaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: provider.expensesList.isEmpty
                ? const Center(child: Text('Belum ada catatan pengeluaran'))
                : ListView.separated(
                    itemCount: provider.expensesList.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final exp = provider.expensesList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          child: const Icon(Icons.outbound, color: Colors.red),
                        ),
                        title: Text(exp['category'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${exp['note']} | ${dateFormat.format(DateTime.parse(exp['date']))}'),
                        trailing: Text(
                          currencyFormat.format(exp['amount']),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        label: const Text('Tambah Biaya'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final categoryController = TextEditingController();
    final noteController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catat Pengeluaran Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Kategori (Listrik, Sewa, dsb)')),
            TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Catatan/Keterangan')),
            CalcTextField(controller: amountController, decoration: const InputDecoration(labelText: 'Jumlah Nominal')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                context.read<BusinessProvider>().addExpense(
                  categoryController.text,
                  noteController.text,
                  double.tryParse(amountController.text) ?? 0,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
