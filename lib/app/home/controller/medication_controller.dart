// medication_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/controller/token_controller.dart';

class MedicationController {
  Future<List<dynamic>> fetchMyPrescriptions() async {
    final bearerToken = await getAccessToken();
    final url = "https://portal.ahmed-hussain.com/api/patient/prescription/my-prescription";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      // The "data" key contains the list of prescriptions
      return jsonData['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load medication prescriptions');
    }
  }
}
