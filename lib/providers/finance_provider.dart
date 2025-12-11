import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/wish_model.dart';
import '../services/file_service.dart';

enum SortOption { recent, value, name }

class FinanceProvider extends ChangeNotifier {
  final FileService _fileService = FileService();
  final Uuid _uuid = const Uuid();

  List<TransactionModel> _transactions = [];
  List<WishModel> _wishes = [];

  bool _isObscure = false;
  String _selectedMonth = DateFormat('MM/yyyy').format(DateTime.now());
  String? _categoryFilterId;
  SortOption _currentSortOption = SortOption.recent;

  final List<CategoryModel> _categories = [
    CategoryModel(id: '1', name: 'Salário', icon: Icons.attach_money, color: Colors.green),
    CategoryModel(id: '2', name: 'Freelance', icon: Icons.work, color: Colors.blue),
    CategoryModel(id: '3', name: 'Investimento', icon: Icons.show_chart, color: Colors.purple),
    CategoryModel(id: '4', name: 'Empréstimo', icon: Icons.handshake, color: Colors.orange),
  ];

  final List<CategoryModel> _wishCategories = [
    CategoryModel(id: 'w1', name: 'Automóvel', icon: Icons.directions_car, color: Colors.redAccent),
    CategoryModel(id: 'w2', name: 'Vestimentas', icon: Icons.checkroom, color: Colors.pinkAccent),
    CategoryModel(id: 'w3', name: 'Ações', icon: Icons.trending_up, color: Colors.amber),
    CategoryModel(id: 'w4', name: 'Eletrônicos', icon: Icons.devices, color: Colors.cyan),
    CategoryModel(id: 'w5', name: 'Viagem', icon: Icons.flight, color: Colors.indigo),
  ];

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get wishCategories => _wishCategories;

  List<WishModel> get wishes {
    List<WishModel> sortedList = List.from(_wishes);
    switch (_currentSortOption) {
      case SortOption.value:
        sortedList.sort((a, b) => a.value.compareTo(b.value));
        break;
      case SortOption.name:
        sortedList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.recent:
      default:
        sortedList.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        break;
    }
    return sortedList;
  }

  bool get isObscure => _isObscure;
  String get selectedMonth => _selectedMonth;
  String? get categoryFilterId => _categoryFilterId;
  SortOption get currentSortOption => _currentSortOption;

  List<TransactionModel> get transactions {
    return _transactions.where((t) {
      final matchesMonth = t.monthRef == _selectedMonth;
      final matchesFilter = _categoryFilterId == null || t.category == _getCategoryNameById(_categoryFilterId!);
      return matchesMonth && matchesFilter;
    }).toList();
  }

  double get totalAmount {
    return transactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get globalTotalAmount {
    return _transactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  // Novo: Soma total dos desejos
  double get totalWishesAmount {
    return _wishes.fold(0.0, (sum, item) => sum + item.value);
  }

  String _getCategoryNameById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id).name;
    } catch (e) {
      return '';
    }
  }

  String _getWishCategoryNameById(String id) {
    try {
      return _wishCategories.firstWhere((c) => c.id == id).name;
    } catch (e) {
      return '';
    }
  }

  FinanceProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _transactions = await _fileService.loadTransactions();
    _wishes = await _fileService.loadWishes();
    notifyListeners();
  }

  void changeMonth(String newMonth) {
    _selectedMonth = newMonth;
    notifyListeners();
  }

  void toggleObscure() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    _categoryFilterId = categoryId;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _currentSortOption = option;
    notifyListeners();
  }

  String addNewCategory(String name) {
    final newCategory = CategoryModel(
      id: _uuid.v4(),
      name: name,
      icon: Icons.bookmark,
      color: Colors.indigo,
    );
    _categories.add(newCategory);
    notifyListeners();
    return newCategory.id;
  }

  Future<void> addTransaction({
    required String description,
    required double amount,
    required String categoryId,
    required bool isRecurring,
  }) async {
    final categoryName = _getCategoryNameById(categoryId);

    final newTransaction = TransactionModel(
      id: _uuid.v4(),
      description: description,
      amount: amount,
      date: DateTime.now(),
      category: categoryName,
      monthRef: _selectedMonth,
      isRecurring: isRecurring,
    );

    _transactions.add(newTransaction);

    if (isRecurring) {
      final parts = _selectedMonth.split('/');
      final currentMonth = int.parse(parts[0]);
      final currentYear = int.parse(parts[1]);
      final nextDate = DateTime(currentYear, currentMonth + 1, 1);
      final nextMonthStr = DateFormat('MM/yyyy').format(nextDate);

      final nextTransaction = TransactionModel(
        id: _uuid.v4(),
        description: description,
        amount: amount,
        date: nextDate,
        category: categoryName,
        monthRef: nextMonthStr,
        isRecurring: false,
      );
      _transactions.add(nextTransaction);
    }

    await _fileService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> editTransaction({
    required String id,
    required String description,
    required double amount,
    required String categoryId,
  }) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final oldTransaction = _transactions[index];
      final categoryName = _getCategoryNameById(categoryId);

      final updatedTransaction = TransactionModel(
        id: oldTransaction.id,
        description: description,
        amount: amount,
        date: oldTransaction.date,
        category: categoryName,
        monthRef: oldTransaction.monthRef,
        isRecurring: oldTransaction.isRecurring,
      );

      _transactions[index] = updatedTransaction;
      await _fileService.saveTransactions(_transactions);
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _fileService.saveTransactions(_transactions);
    notifyListeners();
  }

  String addNewWishCategory(String name) {
    final newCategory = CategoryModel(
      id: _uuid.v4(),
      name: name,
      icon: Icons.card_giftcard,
      color: Colors.teal,
    );
    _wishCategories.add(newCategory);
    notifyListeners();
    return newCategory.id;
  }

  Future<void> addWish({
    required String name,
    required double value,
    required String categoryId,
    required String observation,
  }) async {
    final categoryName = _getWishCategoryNameById(categoryId);

    final newWish = WishModel(
      id: _uuid.v4(),
      name: name,
      value: value,
      category: categoryName,
      observation: observation,
      lastModified: DateTime.now(),
    );

    _wishes.add(newWish);
    await _fileService.saveWishes(_wishes);
    notifyListeners();
  }

  Future<void> editWish({
    required String id,
    required String name,
    required double value,
    required String categoryId,
    required String observation,
  }) async {
    final index = _wishes.indexWhere((w) => w.id == id);
    if (index != -1) {
      final categoryName = _getWishCategoryNameById(categoryId);

      final updatedWish = WishModel(
        id: id,
        name: name,
        value: value,
        category: categoryName,
        observation: observation,
        savedAmount: _wishes[index].savedAmount,
        lastModified: DateTime.now(),
      );

      _wishes[index] = updatedWish;
      await _fileService.saveWishes(_wishes);
      notifyListeners();
    }
  }

  Future<void> deleteWish(String id) async {
    _wishes.removeWhere((w) => w.id == id);
    await _fileService.saveWishes(_wishes);
    notifyListeners();
  }
}