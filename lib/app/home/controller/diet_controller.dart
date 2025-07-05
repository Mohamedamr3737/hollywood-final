// diet_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/controller/token_controller.dart';

class DietController {

  // 1) Fetch the list of diet plans
  Future<List<dynamic>> fetchDietPlans() async {
    final bearerToken = await getAccessToken();
    final url = "https://portal.ahmed-hussain.com/api/patient/prescription/diet-list";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load diet plans');
    }
  }

  // 2) Fetch the days for a specific diet ID
  Future<List<dynamic>> fetchDietDays(int dietId) async {
    final bearerToken = await getAccessToken();
    final url = "https://portal.ahmed-hussain.com/api/patient/prescription/diet-days/?diet_id=$dietId";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load diet days');
    }
  }

  // 3) Fetch the list of diet times (e.g. Breakfast, Lunch, etc.)
  Future<List<dynamic>> fetchDietTimes() async {
    final bearerToken = await getAccessToken();
    final url = "https://portal.ahmed-hussain.com/api/patient/prescription/diet-times";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load diet times');
    }
  }

  // 4) Fetch meals for a given day, diet time, and diet ID
  Future<List<dynamic>> fetchDietMeals({
    required int day,
    required int dietTime,
    required int dietId,
  }) async {
    final bearerToken = await getAccessToken();
    final url = "https://portal.ahmed-hussain.com/api/patient/prescription/diet-meals"
        "?day=$day&diet_time=$dietTime&diet_id=$dietId";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load diet meals');
    }
  }
}
