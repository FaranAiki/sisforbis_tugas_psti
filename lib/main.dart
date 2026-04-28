import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/business_provider.dart';
import 'modules/dashboard/dashboard_page.dart';
import 'modules/erp/erp_page.dart';
import 'modules/crm/crm_page.dart';
import 'modules/queue/queue_page.dart';
import 'modules/finance/finance_page.dart';
import 'modules/hr/hr_page.dart';
import 'modules/expense/expense_page.dart';

void main() {
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => BusinessProvider()..loadData(),
      child: const SisforbisApp(),
    ),
  );
}

class SisforbisApp extends StatelessWidget {
  const SisforbisApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();
    
    TextTheme selectedTextTheme;
    if (provider.fontFamily == 'Times New Roman') {
      selectedTextTheme = GoogleFonts.tinosTextTheme();
    } else if (provider.fontFamily == 'Dyslexic') {
      selectedTextTheme = GoogleFonts.comicNeueTextTheme();
    } else {
      selectedTextTheme = GoogleFonts.outfitTextTheme();
    }

    return MaterialApp(
      title: 'Sisforbis',
      debugShowCheckedModeBanner: false,
      themeMode: provider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        textTheme: selectedTextTheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        textTheme: selectedTextTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: provider.textScale),
          child: child!,
        );
      },
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ERPPage(),
    const FinancePage(),
    const ExpensePage(),
    const HRPage(),
    const CRMPage(),
    const QueuePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            leading: Column(
              children: [
                const SizedBox(height: 20),
                Icon(Icons.business_center, size: 40, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 20),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.accessibility_new),
                        onPressed: () => _showSettingsDialog(context),
                        tooltip: 'Pengaturan',
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: const Icon(Icons.settings_backup_restore, color: Colors.red),
                        onPressed: () => _showResetDatabaseConfirm(context),
                        tooltip: 'Reset Database',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Beranda')),
              NavigationRailDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: Text('ERP')),
              NavigationRailDestination(icon: Icon(Icons.account_balance_outlined), selectedIcon: Icon(Icons.account_balance), label: Text('Laporan')),
              NavigationRailDestination(icon: Icon(Icons.money_off_outlined), selectedIcon: Icon(Icons.money_off), label: Text('Biaya')),
              NavigationRailDestination(icon: Icon(Icons.badge_outlined), selectedIcon: Icon(Icons.badge), label: Text('HR')),
              NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('CRM')),
              NavigationRailDestination(icon: Icon(Icons.format_list_numbered_rtl_outlined), selectedIcon: Icon(Icons.format_list_numbered_rtl), label: Text('Antrean')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final provider = context.read<BusinessProvider>();
    final ppnController = TextEditingController(text: provider.ppnRate.toString());
    final pphController = TextEditingController(text: provider.pphRate.toString());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Pengaturan Aplikasi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tampilan & Aksesibilitas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mode Gelap'),
                    Switch(
                      value: provider.themeMode == ThemeMode.dark,
                      onChanged: (_) {
                        provider.toggleTheme();
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const Text('Keluarga Font'),
                DropdownButton<String>(
                  isExpanded: true,
                  value: provider.fontFamily,
                  items: const [
                    DropdownMenuItem(value: 'Outfit', child: Text('Modern (Outfit)')),
                    DropdownMenuItem(value: 'Times New Roman', child: Text('Resmi (Tinos)')),
                    DropdownMenuItem(value: 'Dyslexic', child: Text('Disleksia (Comic)')),
                  ],
                  onChanged: (val) {
                    provider.setFontFamily(val!);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                const Text('Ukuran Teks'),
                Slider(
                  value: provider.textScale,
                  min: 0.8,
                  max: 1.6,
                  divisions: 4,
                  onChanged: (val) {
                    provider.setTextScale(val);
                    setState(() {});
                  },
                ),
                const Divider(height: 32),
                const Text('Perpajakan (Indonesia UU HPP)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Aktifkan Perhitungan Pajak'),
                    Switch(
                      value: provider.isTaxEnabled,
                      onChanged: (val) {
                        provider.toggleTax(val);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                if (provider.isTaxEnabled) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: ppnController,
                    decoration: const InputDecoration(labelText: 'Tarif PPN (%)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => provider.setPpnRate(double.tryParse(val) ?? 11.0),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pphController,
                    decoration: const InputDecoration(labelText: 'Tarif PPh Final UMKM (%)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => provider.setPphRate(double.tryParse(val) ?? 0.5),
                  ),
                  const SizedBox(height: 4),
                  const Text('*PPh dihitung dari omzet bruto UMKM', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
          ],
        ),
      ),
    );
  }

  void _showResetDatabaseConfirm(BuildContext context) {
    final confirmController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('⚠️ RESET DATABASE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Hapus seluruh data secara permanen.'),
              const SizedBox(height: 16),
              const Text('Ketik "HAPUS" untuk konfirmasi:'),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(hintText: 'HAPUS'),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: confirmController.text == 'HAPUS' 
                  ? () async {
                      await context.read<BusinessProvider>().resetDatabase();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database berhasil direset')));
                      }
                    } 
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('YA, HAPUS SEMUA'),
            ),
          ],
        ),
      ),
    );
  }
}
