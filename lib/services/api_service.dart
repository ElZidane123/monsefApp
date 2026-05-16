import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/models.dart';

// ─── Custom Exception ─────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ─── ApiService ───────────────────────────────────────────────────────────
class ApiService {
  final String _base = ApiConfig.baseUrl;
  final Map<String, String> _headers = ApiConfig.headers;

  // ── Helper ──────────────────────────────────────────────────────────────
  dynamic _extractData(http.Response res) {
    dynamic body;
    try {
      body = json.decode(res.body);
    } catch (_) {
      if (res.statusCode >= 200 && res.statusCode < 300) return null;
      throw ApiException('Invalid JSON response', res.statusCode);
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    }

    final message = (body is Map<String, dynamic> && body.containsKey('message'))
        ? body['message']
        : 'Request failed';
    throw ApiException(message, res.statusCode);
  }

  // ── PROFILE ─────────────────────────────────────────────────────────────
  Future<UserModel> getUserProfile() async {
    final res = await http
        .get(Uri.parse('$_base/profile'), headers: _headers)
        .timeout(ApiConfig.connectTimeout);
    return UserModel.fromJson(_extractData(res));
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final res = await http
        .put(Uri.parse('$_base/profile'),
            headers: _headers, body: json.encode(data))
        .timeout(ApiConfig.connectTimeout);
    return UserModel.fromJson(_extractData(res));
  }

  // ── ACCOUNTS ────────────────────────────────────────────────────────────
  Future<List<AccountModel>> getAccounts() async {
    final res = await http
        .get(Uri.parse('$_base/accounts'), headers: _headers)
        .timeout(ApiConfig.connectTimeout);
    final List data = _extractData(res);
    return data.map((e) => AccountModel.fromJson(e)).toList();
  }

  Future<AccountModel> createAccount(Map<String, dynamic> data) async {
    final res = await http
        .post(Uri.parse('$_base/accounts'),
            headers: _headers, body: json.encode(data))
        .timeout(ApiConfig.connectTimeout);
    return AccountModel.fromJson(_extractData(res));
  }

  Future<AccountModel> updateAccount(String id, Map<String, dynamic> data) async {
    final res = await http
        .put(Uri.parse('$_base/accounts/$id'),
            headers: _headers, body: json.encode(data))
        .timeout(ApiConfig.connectTimeout);
    return AccountModel.fromJson(_extractData(res));
  }

  Future<void> deleteAccount(String id) async {
    final res = await http
        .delete(Uri.parse('$_base/accounts/$id'), headers: _headers)
        .timeout(ApiConfig.connectTimeout);
    _extractData(res);
  }

  // ── TRANSACTIONS ────────────────────────────────────────────────────────
  Future<List<TransactionModel>> getTransactions() async {
    final res = await http
        .get(Uri.parse('$_base/transactions'), headers: _headers)
        .timeout(ApiConfig.connectTimeout);
    final List data = _extractData(res);
    return data.map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<TransactionModel> getTransaction(String id) async {
    final res = await http
        .get(Uri.parse('$_base/transactions/$id'), headers: _headers)
        .timeout(ApiConfig.connectTimeout);
    return TransactionModel.fromJson(_extractData(res));
  }

  Future<TransactionModel> createTransaction(Map<String, dynamic> data) async {
    final res = await http
        .post(Uri.parse('$_base/transactions'),
            headers: _headers, body: json.encode(data))
        .timeout(ApiConfig.connectTimeout);
    return TransactionModel.fromJson(_extractData(res));
  }

  Future<TransactionModel> updateTransaction(
      String id, Map<String, dynamic> data) async {
    final res = await http
        .put(Uri.parse('$_base/transactions/$id'),
            headers: _headers, body: json.encode(data))
        .timeout(ApiConfig.connectTimeout);
    return TransactionModel.fromJson(_extractData(res));
  }

  Future<void> deleteTransaction(String id) async {
    final res = await http
        .delete(Uri.parse('$_base/transactions/$id'), headers: _headers)
        .timeout(ApiConfig.connectTimeout);
    _extractData(res);
  }

  // ── SAVINGS GOALS ───────────────────────────────────────────────────────
  Future<List<SavingsGoalModel>> getSavingsGoals() async {
    final res = await http
        .get(Uri.parse('$_base/savings-goals'), headers: _headers)
        .timeout(ApiConfig.connectTimeout);
    final List data = _extractData(res);
    return data.map((e) => SavingsGoalModel.fromJson(e)).toList();
  }

  Future<SavingsGoalModel> createSavingsGoal(Map<String, dynamic> data) async {
    final res = await http
        .post(Uri.parse('$_base/savings-goals'),
            headers: _headers, body: json.encode(data))
        .timeout(ApiConfig.connectTimeout);
    return SavingsGoalModel.fromJson(_extractData(res));
  }

  Future<SavingsGoalModel> updateSavingsGoal(
      String id, Map<String, dynamic> data) async {
    final res = await http
        .put(Uri.parse('$_base/savings-goals/$id'),
            headers: _headers, body: json.encode(data))
        .timeout(ApiConfig.connectTimeout);
    return SavingsGoalModel.fromJson(_extractData(res));
  }

  Future<void> deleteSavingsGoal(String id) async {
    final res = await http
        .delete(Uri.parse('$_base/savings-goals/$id'), headers: _headers)
        .timeout(ApiConfig.connectTimeout);
    _extractData(res);
  }

  // ── SPENDING SUMMARY ────────────────────────────────────────────────────
  Future<List<SpendingDataModel>> getSpendingSummary(
      {String period = 'monthly'}) async {
    final res = await http
        .get(Uri.parse('$_base/spending/summary?period=$period'),
            headers: _headers)
        .timeout(ApiConfig.connectTimeout);
    final List data = _extractData(res);
    return data
        .map((e) => SpendingDataModel(
              label: e['label'],
              amount: (e['amount'] as num).toDouble(),
              isHighlighted: e['isHighlighted'] ?? false,
            ))
        .toList();
  }
}
