import 'package:flutter/material.dart';
import 'db_helper.dart';

class BusinessProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  // Accessibility State
  ThemeMode _themeMode = ThemeMode.light;
  String _fontFamily = 'Outfit';
  double _textScale = 1.0;

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  double get textScale => _textScale;

  // Tax State (Indonesia UU HPP)
  bool _isTaxEnabled = false;
  double _ppnRate = 11.0;
  double _pphRate = 0.5;

  bool get isTaxEnabled => _isTaxEnabled;
  double get ppnRate => _ppnRate;
  double get pphRate => _pphRate;

  // ERP State
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => _items;

  double _totalProfit = 0; // Omzet (Net Revenue)
  double _totalPpn = 0;
  double _totalPph = 0;
  double _totalExpenses = 0;

  double get totalProfit => _totalProfit;
  double get totalPpn => _totalPpn;
  double get totalPph => _totalPph;
  double get totalExpenses => _totalExpenses;
  double get netProfit => _totalProfit - _totalPph - _totalExpenses;

  // HR State
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> get employees => _employees;

  // Expense State
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> get expensesList => _expenses;

  // Queue State
  int _currentServing = 0;
  int get currentServing => _currentServing;
  int _lastTicket = 0;
  int get lastTicket => _lastTicket;

  // CRM State
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> get customers => _customers;

  Future<void> loadData() async {
    final db = await _dbHelper.database;
    
    _items = await db.query('items');
    
    final res = await db.rawQuery("SELECT SUM(subtotal) as total, SUM(ppnAmount) as ppn FROM transactions WHERE type = 'OUT'");
    _totalProfit = (res.first['total'] as num?)?.toDouble() ?? 0.0;
    _totalPpn = (res.first['ppn'] as num?)?.toDouble() ?? 0.0;
    _totalPph = _totalProfit * (_pphRate / 100);

    final expRes = await db.rawQuery("SELECT SUM(amount) as total FROM expenses");
    _totalExpenses = (expRes.first['total'] as num?)?.toDouble() ?? 0.0;

    final queueRes = await db.rawQuery('SELECT MAX(ticket_number) as last FROM queue_tickets');
    _lastTicket = (queueRes.first['last'] as int?) ?? 0;
    
    final servingRes = await db.rawQuery("SELECT ticket_number FROM queue_tickets WHERE status = 'SERVING' ORDER BY id DESC LIMIT 1");
    _currentServing = (servingRes.isNotEmpty ? servingRes.first['ticket_number'] as int : 0);

    _customers = await db.query('customers');
    _employees = await db.query('employees');
    _expenses = await db.query('expenses', orderBy: 'id DESC');

    notifyListeners();
  }

  // Accessibility Actions
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  void setFontFamily(String font) { _fontFamily = font; notifyListeners(); }
  void setTextScale(double scale) { _textScale = scale; notifyListeners(); }
  void toggleTax(bool value) { _isTaxEnabled = value; notifyListeners(); }
  void setPpnRate(double rate) { _ppnRate = rate; notifyListeners(); }
  void setPphRate(double rate) { _pphRate = rate; notifyListeners(); }

  // ERP Actions
  Future<void> addItem(String name, int stock, double price) async {
    final db = await _dbHelper.database;
    await db.insert('items', {'name': name, 'stock': stock, 'price': price});
    await loadData();
  }

  Future<void> deleteItem(int itemId) async {
    final db = await _dbHelper.database;
    await db.delete('transactions', where: 'itemId = ?', whereArgs: [itemId]);
    await db.delete('items', where: 'id = ?', whereArgs: [itemId]);
    await loadData();
  }

  Future<String?> addTransaction(int itemId, int quantity, String type) async {
    final db = await _dbHelper.database;
    final itemRes = await db.query('items', where: 'id = ?', whereArgs: [itemId]);
    if (itemRes.isEmpty) return 'Barang tidak ditemukan';
    
    final item = itemRes.first;
    int currentStock = item['stock'] as int;

    if (type == 'OUT' && currentStock < quantity) {
      return 'Stok tidak mencukupi!';
    }

    double price = (item['price'] as num).toDouble();
    double subtotal = price * quantity;
    double ppnAmount = (type == 'OUT' && _isTaxEnabled) ? subtotal * (_ppnRate / 100) : 0;
    double totalPrice = subtotal + ppnAmount;

    await db.insert('transactions', {
      'itemId': itemId,
      'quantity': quantity,
      'type': type,
      'date': DateTime.now().toIso8601String(),
      'subtotal': subtotal,
      'ppnAmount': ppnAmount,
      'totalPrice': totalPrice,
    });

    int newStock = currentStock + (type == 'IN' ? quantity : -quantity);
    await db.update('items', {'stock': newStock}, where: 'id = ?', whereArgs: [itemId]);
    await loadData();
    return null;
  }

  Future<String?> quickAdjustStock(int itemId, int delta) async {
    final db = await _dbHelper.database;
    final itemRes = await db.query('items', where: 'id = ?', whereArgs: [itemId]);
    if (itemRes.isEmpty) return 'Barang tidak ditemukan';
    
    final item = itemRes.first;
    int currentStock = item['stock'] as int;
    int newStock = currentStock + delta;
    if (newStock < 0) return 'Stok tidak boleh negatif!';

    double price = (item['price'] as num).toDouble();
    double subtotal = price * delta.abs();
    double ppnAmount = (delta < 0 && _isTaxEnabled) ? subtotal * (_ppnRate / 100) : 0;
    
    await db.insert('transactions', {
      'itemId': itemId,
      'quantity': delta.abs(),
      'type': delta > 0 ? 'IN' : 'OUT',
      'date': DateTime.now().toIso8601String(),
      'subtotal': delta > 0 ? 0.0 : subtotal,
      'ppnAmount': delta > 0 ? 0.0 : ppnAmount,
      'totalPrice': delta > 0 ? 0.0 : (subtotal + ppnAmount),
    });

    await db.update('items', {'stock': newStock}, where: 'id = ?', whereArgs: [itemId]);
    await loadData();
    return null;
  }

  // HR Actions
  Future<void> addEmployee(String name, String role, double salary) async {
    final db = await _dbHelper.database;
    await db.insert('employees', {
      'name': name,
      'role': role,
      'salary': salary,
      'joinedDate': DateTime.now().toIso8601String(),
    });
    await loadData();
  }

  Future<void> deleteEmployee(int id) async {
    final db = await _dbHelper.database;
    await db.delete('employees', where: 'id = ?', whereArgs: [id]);
    await loadData();
  }

  // Expense Actions
  Future<void> addExpense(String category, String note, double amount) async {
    final db = await _dbHelper.database;
    await db.insert('expenses', {
      'category': category,
      'note': note,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
    });
    await loadData();
  }

  // Finance Actions
  Future<List<Map<String, dynamic>>> getDetailedTransactions() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT t.*, i.name as itemName 
      FROM transactions t 
      LEFT JOIN items i ON t.itemId = i.id 
      ORDER BY t.date DESC
    ''');
  }

  // Queue Actions
  Future<void> issueTicket() async {
    final db = await _dbHelper.database;
    await db.insert('queue_tickets', {
      'ticket_number': _lastTicket + 1,
      'status': 'WAITING',
      'timestamp': DateTime.now().toIso8601String(),
    });
    await loadData();
  }

  Future<void> callNext() async {
    final db = await _dbHelper.database;
    await db.update('queue_tickets', {'status': 'COMPLETED'}, where: 'status = ?', whereArgs: ['SERVING']);
    final nextRes = await db.query('queue_tickets', where: 'status = ?', orderBy: 'id ASC', limit: 1, whereArgs: ['WAITING']);
    if (nextRes.isNotEmpty) {
      await db.update('queue_tickets', {'status': 'SERVING'}, where: 'id = ?', whereArgs: [nextRes.first['id'] as int]);
    }
    await loadData();
  }

  // CRM Actions
  Future<void> addCustomer(String name, String email, String phone) async {
    final db = await _dbHelper.database;
    await db.insert('customers', {'name': name, 'email': email, 'phone': phone});
    await loadData();
  }

  Future<void> addInteraction(int customerId, String note, int rating) async {
    final db = await _dbHelper.database;
    await db.insert('interactions', {'customerId': customerId, 'note': note, 'rating': rating, 'date': DateTime.now().toIso8601String()});
    await loadData();
  }

  Future<List<Map<String, dynamic>>> getInteractions(int customerId) async {
    final db = await _dbHelper.database;
    return await db.query('interactions', where: 'customerId = ?', whereArgs: [customerId], orderBy: 'id DESC');
  }

  Future<void> resetDatabase() async {
    await _dbHelper.clearAllData();
    await loadData();
  }
}
