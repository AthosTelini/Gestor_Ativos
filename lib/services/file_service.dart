import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/transaction_model.dart';
import '../models/wish_model.dart';

class FileService {
  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  // --- Transações ---
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final file = File(await _getFilePath('dados_financeiros.json'));
    final List<Map<String, dynamic>> data = transactions.map((t) => t.toMap()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  Future<List<TransactionModel>> loadTransactions() async {
    try {
      final file = File(await _getFilePath('dados_financeiros.json'));
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);
      return data.map((item) => TransactionModel.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // --- Desejos ---
  Future<void> saveWishes(List<WishModel> wishes) async {
    final file = File(await _getFilePath('dados_desejos.json'));
    final List<Map<String, dynamic>> data = wishes.map((w) => w.toMap()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  Future<List<WishModel>> loadWishes() async {
    try {
      final file = File(await _getFilePath('dados_desejos.json'));
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);
      return data.map((item) => WishModel.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }
}