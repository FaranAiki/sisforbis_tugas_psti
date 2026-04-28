import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/business_provider.dart';
import '../../core/utils/pdf_generator.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan & Perpajakan'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Master PDF'),
            onPressed: () async {
              final txs = await provider.getDetailedTransactions();
              if (context.mounted) {
                await PdfGenerator.generateAndShareReport(
                  transactions: txs,
                  items: provider.items,
                  customers: provider.customers,
                  employees: provider.employees,
                  expenses: provider.expensesList,
                  omzet: provider.totalProfit,
                  totalPpn: provider.totalPpn,
                  totalPph: provider.totalPph,
                  totalExpenses: provider.totalExpenses,
                );
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaxSummary(context, provider, currencyFormat),
            const SizedBox(height: 32),
            const Text('Riwayat Transaksi Detail', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: provider.getDetailedTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Belum ada transaksi'));
                }

                final txs = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txs.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final isOut = tx['type'] == 'OUT';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isOut ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        child: Icon(isOut ? Icons.shopping_cart : Icons.add_business, color: isOut ? Colors.blue : Colors.green, size: 20),
                      ),
                      title: Text(tx['itemName'] ?? 'Barang Dihapus', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(dateFormat.format(DateTime.parse(tx['date']))),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isOut ? "-" : "+"}${tx['quantity']} Item',
                            style: TextStyle(fontWeight: FontWeight.bold, color: isOut ? Colors.blue : Colors.green),
                          ),
                          Text(currencyFormat.format(tx['totalPrice']), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
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

  Widget _buildTaxSummary(BuildContext context, BusinessProvider provider, NumberFormat format) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RINGKASAN KEUANGAN & PAJAK (ID)', style: TextStyle(letterSpacing: 1.2, fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 20),
          _buildSummaryRow('Omzet Bruto (Pendapatan)', format.format(provider.totalProfit), isBold: true),
          const SizedBox(height: 12),
          _buildSummaryRow('PPN Terpungut (${provider.ppnRate}%)', format.format(provider.totalPpn), color: Colors.orange),
          _buildSummaryRow('Total Biaya Operasional', '- ${format.format(provider.totalExpenses)}', color: Colors.red),
          _buildSummaryRow('PPh Final UMKM (${provider.pphRate}%)', '- ${format.format(provider.totalPph)}', color: Colors.red),
          const Divider(height: 32),
          _buildSummaryRow('Estimasi Laba Bersih', format.format(provider.netProfit), isBold: true, fontSize: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          const Text('*Laba bersih = Omzet - Biaya - PPh Final', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, double fontSize = 14, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
