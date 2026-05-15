import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'https://learn.smktelkom-mlg.sch.id/api'; // Placeholder based on reference project

  Future<List<TransactionModel>> getTransactions() async {
    final response = await http.get(Uri.parse('$baseUrl/transactions'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<UserModel> getUserProfile() async {
    final response = await http.get(Uri.parse('$baseUrl/user/profile'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['data'];
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<List<AccountModel>> getAccounts() async {
    final response = await http.get(Uri.parse('$baseUrl/accounts'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => AccountModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load accounts');
    }
  }
}
