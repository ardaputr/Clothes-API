import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clothing.dart';

class ApiService {
  static const baseUrl =
      'https://tpm-api-tugas-872136705893.us-central1.run.app/api/clothes';

  static Future<List<Clothing>> fetchAllClothes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> data = jsonData['data'];
      return data.map((e) => Clothing.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load clothes');
    }
  }

  static Future<Clothing> fetchClothingById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Clothing.fromJson(jsonData['data']);
    } else {
      throw Exception('Clothing not found');
    }
  }

  static Future<void> createClothing(Clothing clothing) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(clothing.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create clothing');
    }
  }

  static Future<void> updateClothing(int id, Clothing clothing) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(clothing.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update clothing');
    }
  }

  static Future<void> deleteClothing(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete clothing');
    }
  }
}
