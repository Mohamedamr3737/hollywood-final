import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/controller/token_controller.dart';
import 'package:get/get.dart';
import '../../../general/consts/consts.dart';

class AppointmentsController extends GetxController {
  final String apiUrl =
      "https://portal.ahmed-hussain.com/api/patient/appointments";

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var settings = <Map<String, dynamic>>[].obs;

  /// Fetch the list of appointments from the API.
  Future<List<Map<String, String>>> fetchAppointments() async {
    String? bearerToken = await getAccessToken();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    if (response.statusCode == 200 && jsonResponse['status'] == true) {
      final List<dynamic> appointmentsData = jsonResponse['data'];
      return appointmentsData.map<Map<String, String>>((item) {
        return {
          "id": item['id'].toString(),
          "appointmentName": item['type'] ?? '',
          "doctor": item['doctor'] ?? '',
          "department": item['department'] ?? '',
          "date": item['date'] ?? '',
          "time": item['time'] ?? '',
        };
      }).toList();
    } else {
      throw Exception("Failed to load appointments: ${response.statusCode}");
    }
  }

  /// Fetch settings (departments, doctors, services, and times) from the API for a given date.
  /// The API expects the date in "YYYY/MM/DD" format.
  Future<void> fetchSettings(String date) async {
    try {
      isLoading(true);
      errorMessage('');
      final formattedDate = date.replaceAll('-', '/');
      var bearerToken = await getAccessToken();
      final url =
          "https://portal.ahmed-hussain.com/api/patient/appointments/setting?date=$formattedDate";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          settings.value = List<Map<String, dynamic>>.from(jsonData['data']);
        } else {
          errorMessage.value = jsonData['message'] ?? "No settings available.";
        }
      } else {
        errorMessage.value = "HTTP Error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong!";
      print("Exception in fetchSettings: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Store a new appointment using the API.
  /// Parameters:
  /// - [date]: in "YYYY-MM-DD" format (will be converted to "YYYY/MM/DD")
  /// - [time]: in a format like "9:00:00PM"
  /// - [doctorId], [serviceId], [deptId], [branchId]: IDs for the appointment.
  Future<bool> storeAppointment({
    required String date,
    required String time,
    required int doctorId,
    required int serviceId,
    required int deptId,
    required int branchId,
  }) async {
    try {
      isLoading(true);
      var bearerToken = await getAccessToken();
      final formattedDate = date.replaceAll('-', '/');
      final url =
          "https://portal.ahmed-hussain.com/api/patient/appointments/store";
      final body = json.encode({
        "date": formattedDate,
        "time": time,
        "doctor_id": doctorId,
        "service_id": serviceId,
        "dept_id": deptId,
        "branch_id": branchId,
      });
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json'
        },
        body: body,
      );
      final jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData["status"] == true) {
        return true;
      } else {
        errorMessage.value =
            jsonData["message"] ?? "Failed to store appointment";
        return false;
      }
    } catch (e) {
      errorMessage.value = "Something went wrong!";
      print("Exception in storeAppointment: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// Cancel an appointment using the API.
  /// Sends the appointment ID in the request body.
  Future<bool> cancelAppointment({required int id}) async {
    try {
      isLoading(true);
      final bearerToken = await getAccessToken();
      final url = "https://portal.ahmed-hussain.com/api/patient/appointments/cancel";
      final body = json.encode({"id": id});
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      final jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData["status"] == true) {
        return true;
      } else {
        errorMessage.value =
            jsonData["message"] ?? "Failed to cancel appointment";
        return false;
      }
    } catch (e) {
      errorMessage.value = "Something went wrong!";
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// This method cancels the appointment and pops the current screen.
  /// NOTE: Typically, it's better to let the widget handle pop(), but if you want
  /// the controller to handle it, ensure you pass a non-null Map<String, String>.
  Future<void> cancelAppointmentAndPop({
    required BuildContext context,
    required int id,
  }) async {
    final success = await cancelAppointment(id: id);
    if (success) {
      // Always pass a Map<String, String> with non-null values:
      Navigator.of(context).pop({
        'action': 'cancel',
        'id': id.toString(), // Convert int to non-null String
      });
    } else {
      // Show an error message or do nothing.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage.value)),
      );
    }
  }
}
