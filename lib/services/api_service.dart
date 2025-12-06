import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class ApiService {
  // Untuk emulator Android:
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // Kalau test di device fisik, ganti dengan IP laptop kamu, misal:
  // static const String baseUrl = 'http://192.168.1.10:8000/api';

  // ===== AUTH =====
  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    return response.statusCode == 201;
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final user = data['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', user['id']);
        await prefs.setString('user_name', user['name']);
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ===== BOOKS =====

  Future<List<Book>> getBooks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/books'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => Book.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data buku: ${response.statusCode}');
    }
  }

  Future<bool> createBook(Book book) async {
    final url = Uri.parse('$baseUrl/books');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(book.toJson()),
    );

    // Debug (boleh dihapus setelah yakin)
    // ignore: avoid_print
    print('createBook status: ${response.statusCode}');
    // ignore: avoid_print
    print('createBook body  : ${response.body}');

    return response.statusCode == 201;
  }

  Future<bool> updateBook(Book book) async {
    if (book.id == null) return false;

    final url = Uri.parse('$baseUrl/books/${book.id}');
    final response = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(book.toJson()),
    );

    // Debug (boleh dihapus setelah yakin)
    // ignore: avoid_print
    print('updateBook status: ${response.statusCode}');
    // ignore: avoid_print
    print('updateBook body  : ${response.body}');

    return response.statusCode == 200;
  }

  Future<bool> deleteBook(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/books/$id'),
      headers: {'Accept': 'application/json'},
    );

    // ignore: avoid_print
    print('deleteBook status: ${response.statusCode}');
    // ignore: avoid_print
    print('deleteBook body  : ${response.body}');

    return response.statusCode == 200;
  }
}
