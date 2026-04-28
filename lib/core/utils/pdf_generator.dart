import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static Future<void> generateAndShareReport({
    required List<Map<String, dynamic>> transactions,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> customers,
    required List<Map<String, dynamic>> employees,
    required List<Map<String, dynamic>> expenses,
    required double omzet,
    required double totalPpn,
    required double totalPph,
    required double totalExpenses,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Halaman ${context.pageNumber} dari ${context.pagesCount} | Dokumen Rahasia Perusahaan',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SISFORBIS ERP', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                    pw.Text('Laporan Master Perusahaan (Complete Report)', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  ],
                ),
                pw.Text(dateFormat.format(DateTime.now()), style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // 1. Financial Summary Section
          _pdfSectionTitle('I. RINGKASAN KEUANGAN & PAJAK'),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              children: [
                _pdfSummaryRow('Total Omzet Bruto:', currencyFormat.format(omzet)),
                _pdfSummaryRow('Total PPN Terpungut:', currencyFormat.format(totalPpn)),
                _pdfSummaryRow('Total Biaya Operasional:', '- ${currencyFormat.format(totalExpenses)}', color: PdfColors.red900),
                _pdfSummaryRow('Total PPh Final UMKM (0.5%):', '- ${currencyFormat.format(totalPph)}', color: PdfColors.red900),
                pw.Divider(),
                _pdfSummaryRow('ESTIMASI LABA BERSIH:', currencyFormat.format(omzet - totalExpenses - totalPph), isBold: true, color: PdfColors.green900),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // 2. Inventory Section
          _pdfSectionTitle('II. STATUS INVENTARIS BARANG'),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo700),
            headers: ['Nama Barang', 'Stok Saat Ini', 'Harga Jual', 'Nilai Aset'],
            data: items.map((i) => [
              i['name'],
              i['stock'].toString(),
              currencyFormat.format(i['price']),
              currencyFormat.format((i['price'] as num) * (i['stock'] as int)),
            ]).toList(),
          ),
          pw.SizedBox(height: 20),

          // 3. Human Resources
          _pdfSectionTitle('III. SUMBER DAYA MANUSIA (KARYAWAN)'),
          employees.isEmpty 
            ? pw.Text('Tidak ada data karyawan.')
            : pw.TableHelper.fromTextArray(
                headers: ['Nama', 'Jabatan', 'Gaji Bulanan'],
                data: employees.map((e) => [e['name'], e['role'], currencyFormat.format(e['salary'])]).toList(),
              ),
          pw.SizedBox(height: 20),

          // 4. CRM Section
          _pdfSectionTitle('IV. DATA PELANGGAN (CRM)'),
          customers.isEmpty 
            ? pw.Text('Tidak ada data pelanggan.')
            : pw.TableHelper.fromTextArray(
                headers: ['Nama Pelanggan', 'Email', 'Telepon'],
                data: customers.map((c) => [c['name'], c['email'], c['phone']]).toList(),
              ),
          pw.SizedBox(height: 20),

          // 5. Recent Transactions
          _pdfSectionTitle('V. RIWAYAT TRANSAKSI TERAKHIR (Top 20)'),
          pw.TableHelper.fromTextArray(
            headers: ['Tanggal', 'Item', 'Tipe', 'Qty', 'Total'],
            data: transactions.take(20).map((t) => [
              dateFormat.format(DateTime.parse(t['date'])),
              t['itemName'] ?? 'N/A',
              t['type'] == 'IN' ? 'Masuk' : 'Jual',
              t['quantity'].toString(),
              currencyFormat.format(t['totalPrice']),
            ]).toList(),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(), 
      filename: 'Master_Report_Sisforbis_${DateTime.now().millisecondsSinceEpoch}.pdf'
    );
  }

  static pw.Widget _pdfSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
    );
  }

  static pw.Widget _pdfSummaryRow(String label, String value, {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
