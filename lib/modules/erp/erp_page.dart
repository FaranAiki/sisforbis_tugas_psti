import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/business_provider.dart';
import '../../core/widgets/calc_text_field.dart';

class ERPPage extends StatelessWidget {
  const ERPPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Simple ERP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatCard(context, 'Total Omzet (Kotor)', currencyFormat.format(provider.totalProfit), Icons.payments, Colors.green),
                const SizedBox(width: 16),
                _buildStatCard(context, 'Total Barang', provider.items.length.toString(), Icons.category, Colors.blue),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Inventaris Barang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.items.length,
                  separatorBuilder: (context, index) => const Divider(height: 32),
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    final int stock = item['stock'] as int;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('Harga: ${currencyFormat.format(item['price'])}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20),
                                  onPressed: stock > 0 
                                    ? () => provider.quickAdjustStock(item['id'], -1)
                                    : null,
                                  tooltip: 'Kurangi 1',
                                ),
                                Text('$stock', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: () => provider.quickAdjustStock(item['id'], 1),
                                  tooltip: 'Tambah 1',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.history_edu, color: Colors.blue),
                            tooltip: 'Transaksi Masal',
                            onPressed: () => _showTransactionSheet(context, item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            tooltip: 'Hapus Barang',
                            onPressed: () => _showDeleteConfirm(context, item['id'], item['name']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        label: const Text('Tambah Barang'),
        icon: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final stockController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          String? nameError;
          if (nameController.text.isNotEmpty && nameController.text.trim().isEmpty) {
            nameError = 'Nama tidak boleh hanya spasi';
          }

          int? stock = int.tryParse(stockController.text);
          String? stockError;
          if (stockController.text.isNotEmpty && (stock == null || stock < 0)) {
            stockError = 'Stok tidak boleh negatif';
          }

          double? price = double.tryParse(priceController.text);
          String? priceError;
          if (priceController.text.isNotEmpty && (price == null || price < 0)) {
            priceError = 'Harga tidak boleh negatif';
          }

          bool isValid = nameController.text.trim().isNotEmpty && 
                         stock != null && stock >= 0 && 
                         price != null && price >= 0;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Tambah Barang Baru'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController, 
                  decoration: InputDecoration(labelText: 'Nama Barang', errorText: nameError, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                CalcTextField(
                  controller: stockController, 
                  decoration: InputDecoration(labelText: 'Stok Awal', errorText: stockError, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                CalcTextField(
                  controller: priceController, 
                  decoration: InputDecoration(labelText: 'Harga Jual', errorText: priceError, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
              ElevatedButton(
                onPressed: isValid ? () {
                  context.read<BusinessProvider>().addItem(nameController.text.trim(), stock!, price!);
                  Navigator.pop(context);
                } : null,
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Simpan'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showTransactionSheet(BuildContext context, Map<String, dynamic> item) {
    final provider = context.read<BusinessProvider>();
    final qtyController = TextEditingController();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    String type = 'OUT';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          int? qty = int.tryParse(qtyController.text);
          double subtotal = (qty ?? 0) * (item['price'] as num).toDouble();
          double ppn = (type == 'OUT' && provider.isTaxEnabled) ? subtotal * (provider.ppnRate / 100) : 0;
          double grandTotal = subtotal + ppn;

          bool canProcess = qty != null && qty > 0 && (type == 'IN' || qty <= (item['stock'] as int));

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 32, right: 32, top: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Stok Saat Ini: ${item['stock']}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'OUT', label: Text('Penjualan'), icon: Icon(Icons.shopping_cart_checkout)),
                    ButtonSegment(value: 'IN', label: Text('Stok Masuk'), icon: Icon(Icons.add_business)),
                  ],
                  selected: {type},
                  onSelectionChanged: (val) => setState(() => type = val.first),
                ),
                const SizedBox(height: 24),
                CalcTextField(
                  controller: qtyController,
                  decoration: InputDecoration(
                    labelText: 'Jumlah Kuantitas',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.numbers),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:'),
                          Text(currencyFormat.format(subtotal)),
                        ],
                      ),
                      if (type == 'OUT' && provider.isTaxEnabled) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('PPN (${provider.ppnRate}%):', style: const TextStyle(color: Colors.orange)),
                            Text(currencyFormat.format(ppn), style: const TextStyle(color: Colors.orange)),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Akhir:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(currencyFormat.format(grandTotal), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: canProcess ? () async {
                      final error = await provider.addTransaction(item['id'], qty!, type);
                      if (context.mounted) {
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                        } else {
                          Navigator.pop(context);
                        }
                      }
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(type == 'OUT' ? 'Proses Penjualan' : 'Simpan Stok Masuk', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, int itemId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Barang'),
        content: Text('Hapus "$name"? Data transaksi terkait juga akan hilang.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              context.read<BusinessProvider>().deleteItem(itemId);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
