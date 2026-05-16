import 'package:dio/dio.dart';
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
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: const Duration(seconds: 15),
        headers: ApiConfig.headers,
        validateStatus: (status) => status != null && status < 500, // Let us handle errors
      ),
    );
  }

  // ── Helper ──────────────────────────────────────────────────────────────
  dynamic _extractData(Response res) {
    if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
      final body = res.data;
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    }

    String message = 'Request failed';
    if (res.data is Map<String, dynamic> && res.data.containsKey('message')) {
      message = res.data['message'];
    }
    throw ApiException(message, res.statusCode);
  }

  ApiException _handleError(dynamic e) {
    if (e is ApiException) return e;
    if (e is DioException) {
      return ApiException(e.message ?? 'Network error', e.response?.statusCode);
    }
    return ApiException(e.toString());
  }

  // ── AUTHENTICATION ────────────────────────────────────────────────────────
  Future<UserModel> login(String email, String password) async {
    try {
      final res = await _dio.get('/users', queryParameters: {'email': email, 'password': password});
      final List data = _extractData(res);
      if (data.isEmpty) {
        throw ApiException('Email atau password salah', 401);
      }
      return UserModel.fromJson(data.first);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/users', data: data);
      return UserModel.fromJson(_extractData(res));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── PROFILE ─────────────────────────────────────────────────────────────
  Future<UserModel> getUserProfile() async {
    try {
      final res = await _dio.get('/profile');
      return UserModel.fromJson(_extractData(res));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('/profile', data: data);
      return UserModel.fromJson(_extractData(res));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── ACCOUNTS ────────────────────────────────────────────────────────────
  Future<List<AccountModel>> getAccounts() async {
    try {
      final res = await _dio.get('/accounts');
      final List data = _extractData(res);
      return data.map((e) => AccountModel.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AccountModel> createAccount(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/accounts', data: data);
      return AccountModel.fromJson(_extractData(res));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AccountModel> updateAccount(String id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('/accounts/$id', data: data);
      return AccountModel.fromJson(_extractData(res));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      final res = await _dio.delete('/accounts/$id');
      _extractData(res);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── TRANSACTIONS ────────────────────────────────────────────────────────
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final res = await _dio.get('/transactions');
      final List data = _extractData(res);
      return data.map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TransactionModel> getTransaction(String id) async {
    try {
      final res = await _dio.get('/transactions/$id');
      return TransactionModel.fromJson(_extractData(res));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TransactionModel> createTransaction(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/transactions', data: data);
      return TransactionModel.fromJson(_extractData(res));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TransactionModel> updateTransaction(String id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('/transactions/$id', data: data);
      return TransactionModel.fromJson(_extractData(res));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final res = await _dio.delete('/transactions/$id');
      _extractData(res);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── SAVINGS GOALS ───────────────────────────────────────────────────────
  Future<List<SavingsGoalModel>> getSavingsGoals() async {
    try {
      final res = await _dio.get('/savings-goals');
      final List data = _extractData(res);
      return data.map((e) => SavingsGoalModel.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<SavingsGoalModel> createSavingsGoal(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/savings-goals', data: data);
      return SavingsGoalModel.fromJson(_extractData(res));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<SavingsGoalModel> updateSavingsGoal(String id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('/savings-goals/$id', data: data);
      return SavingsGoalModel.fromJson(_extractData(res));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteSavingsGoal(String id) async {
    try {
      final res = await _dio.delete('/savings-goals/$id');
      _extractData(res);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── SPENDING SUMMARY ────────────────────────────────────────────────────
  Future<List<SpendingDataModel>> getSpendingSummary({String period = 'monthly'}) async {
    try {
      final res = await _dio.get('/spending/summary', queryParameters: {'period': period});
      final List data = _extractData(res);
      return data
          .map((e) => SpendingDataModel(
                label: e['label'],
                amount: (e['amount'] as num).toDouble(),
                isHighlighted: e['isHighlighted'] ?? false,
              ))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
}
