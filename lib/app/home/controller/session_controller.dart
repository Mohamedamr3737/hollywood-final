import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../general/consts/consts.dart';
import '../../../general/services/alert_service.dart';
import '../../auth/controller/token_controller.dart';

class SessionController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var errorMessage2 = ''.obs;
  var successMessage = ''.obs;
  // Separate lists for regions and session details
  var regions = <Map<String, dynamic>>[].obs;  // Holds session regions
  var sessionDetails = <Map<String, dynamic>>[].obs;  // Holds details of sessions in a region
  var availableTimes = <Map<String, dynamic>>[].obs; // ✅ For session times

  @override
  void onInit() async {
    super.onInit();
    fetchSessions();
  }


  /// ✅ Fetch Available Times for a Session
  Future<void> fetchAvailableTimes(int sessionId, String date) async {
    try {
      isLoading(true);
      availableTimes.clear();
      var bearerToken = await getAccessToken();
      errorMessage.value = "";

      // Ensure date is in YYYY-MM-DD format
      DateTime parsedDate = DateTime.parse(date);
      String formattedDate =
          "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";

      final url =
          "${ApiConfig.baseUrl}/api/patient/sessions/session-time?session_id=$sessionId&date=$formattedDate";


      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData["status"] == true && jsonData["data"] != null) {
          availableTimes.value = List<Map<String, dynamic>>.from(
            jsonData["data"].map((item) {
              return {
                "time": item["value"] ?? "No time",
                "room_id": item["room_id"] ?? 0,
              };
            }),
          );
        } else {
          errorMessage.value = "No available times found.";
        }
      } else {
        errorMessage.value = "HTTP Error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong!";

    } finally {
      isLoading(false);
    }
  }
  /// **Fetch Available Regions**
  Future<void> fetchSessions() async {
    try {
      isLoading(true);
      var bearerToken= await getAccessToken();
      errorMessage.value = "";


      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/patient/sessions/region"),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData["status"] == true && jsonData["data"] != null) {
          regions.value = List<Map<String, dynamic>>.from(jsonData["data"]);
        } else {
          errorMessage.value = "No regions found.";
        }
      } else {
        errorMessage.value = "HTTP Error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong!";
    } finally {
      isLoading(false);
    }
  }

  /// **Fetch Sessions Inside a Region**
  Future<void> fetchSessionDetails(int regionId) async {
    try {
      isLoading(true);
      var bearerToken= await getAccessToken();
      errorMessage2.value = "";
      sessionDetails.clear();  // Clear old session details before fetching new ones


      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/patient/sessions?region_id=$regionId"),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData["status"] == true && jsonData["data"] != null) {
          sessionDetails.value = List<Map<String, dynamic>>.from(jsonData["data"].map((session) {
            return {
              "id": session["id"] ?? 0,
              "title": session["title"] ?? "Unknown",
              "time": session["time"]?.toString().isNotEmpty == true ? session["time"] : "No time provided",
              "date": session["date"]?.toString().isNotEmpty == true ? session["date"] : "No date provided",
              "department_id": session["department_id"] ?? 0,
              "department": session["department"] ?? "General",
              "region_id": session["region_id"] ?? 0,
              "region": session["region"] ?? "Unknown Region",
              "doctor": session["doctor"] ?? "No Doctor Assigned",
              "branch_id": session["branch_id"] ?? 0,
              "branch": session["branch"] ?? "Unknown Branch",
              "cost": session["cost"] ?? "0.00",
              "afterDiscount": session["afterDiscount"] ?? "0.00",
              "active": session["active"] ?? "No",
              "complete": session["complete"] ?? "No",
              "status": session["status"] ?? "Pending",
              "refuse_reason": session["refuse_reason"] ?? "None",
              "set_time": session["set_time"] ?? false,
              "note_before": session["note_before"] ?? "No Notes",
              "note_after": session["note_after"] ?? "No Notes",
              "next_session": session["next_session"] is bool ? session["next_session"] : false,
              "confirmed": session["confirmed"] ?? "No",
              "created_at": session["created_at"] ?? "1970-01-01T00:00:00.000000Z",
              "updated_at": session["updated_at"] ?? "1970-01-01T00:00:00.000000Z",
            };
          }));
        } else {
          errorMessage2.value = "No sessions found in this region.";
        }
      } else {
        errorMessage2.value = "HTTP Error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage2.value = "Something went wrong!";
    } finally {
      isLoading(false);
    }
  }

  /// **Clear session details when exiting a region page**
  void clearSessionDetails() {
    sessionDetails.clear();
  }

  Future<bool> setSessionTime({
    required int sessionId,
    required String date,
    required String time,
    required int roomId,
    required context,
  }) async {
    bool isSuccess = false;
    try {
      isLoading(true);
      var bearerToken = await getAccessToken();
      successMessage.value = "";

      // **Format Date (YYYY-MM-DD)**
      DateTime parsedDate = DateTime.parse(date);
      String formattedDate =
          "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";

      // **Fix Time Format (HH:mm:ssAM/PM)**
      List<String> timeParts = time.split(":");
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1].split(" ")[0]);
      String period = timeParts[1].contains("PM") ? "PM" : "AM";

      String formattedTime =
          "$hour:${minute.toString().padLeft(2, '0')}:00$period"; // Ensure g:i:sA format

      final Uri url = Uri.parse(
          "${ApiConfig.baseUrl}/api/patient/sessions/set-time"
              "?date=$formattedDate&time=$formattedTime&room_id=$roomId&session_id=$sessionId");


      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );


      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonData["status"] == true) {
          successMessage.value =
              jsonData["message"] ?? "Time set successfully!";
          AlertService.success(context, successMessage.value);
          await fetchSessionDetails(jsonData['data']['region_id']);
          // update(); // ✅ Forces UI Rebuild
          isSuccess=true;
          } else {
            // print(jsonData["message"]["date"][0]);
            // Handle different message formats
            String errorMsg = "Failed to set time.";
            if (jsonData["message"] is Map) {
              // Check for different field errors (date, time, room_id, etc.)
              if (jsonData["message"]["date"] is List && jsonData["message"]["date"].isNotEmpty) {
                errorMsg = jsonData["message"]["date"][0];
              } else if (jsonData["message"]["time"] is List && jsonData["message"]["time"].isNotEmpty) {
                errorMsg = jsonData["message"]["time"][0];
              } else if (jsonData["message"]["room_id"] is List && jsonData["message"]["room_id"].isNotEmpty) {
                errorMsg = jsonData["message"]["room_id"][0];
              } else if (jsonData["message"]["session_id"] is List && jsonData["message"]["session_id"].isNotEmpty) {
                errorMsg = jsonData["message"]["session_id"][0];
              } else {
                // If no specific field error, get the first available error
                var firstError = jsonData["message"].values.firstWhere(
                  (value) => value is List && value.isNotEmpty,
                  orElse: () => null,
                );
                if (firstError != null && firstError.isNotEmpty) {
                  errorMsg = firstError[0];
                }
              }
            } else if (jsonData["message"] is String) {
              errorMsg = jsonData["message"];
            }
            AlertService.error(context, errorMsg);
          }
      } else {
        AlertService.serverError(context, "HTTP Error: ${response.statusCode}");
      }
    } catch (e) {

      AlertService.error(context, e.toString());
      print(e);
    } finally {
      isLoading(false);
    }

    return isSuccess;
  }

  Future<bool> cancelSessionTime({
    required int sessionId,
    required context,
  }) async {
    bool isSuccess = false;
    try {
      isLoading(true);
      var bearerToken = await getAccessToken();
      successMessage.value = "";

      final Uri url = Uri.parse(
        "${ApiConfig.baseUrl}/api/patient/sessions/cancel-time?session_id=$sessionId",
      );


      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );


      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonData["status"] == true) {
          successMessage.value =
              jsonData["message"] ?? "Time canceled successfully!";
          AlertService.success(context, successMessage.value);

          // Refresh session data if needed
          await fetchSessionDetails(jsonData['data']['region_id']);

          // Indicate success
          isSuccess = jsonData['status'];
        } else {
          // Handle different message formats
          String errorMsg = "Failed to cancel time.";
          if (jsonData["message"] is Map) {
            // If message is a map, try to get the first error or use a default
            if (jsonData["message"].values.isNotEmpty) {
              errorMsg = jsonData["message"].values.first.toString();
            }
          } else if (jsonData["message"] is String) {
            errorMsg = jsonData["message"];
          }
          AlertService.error(context, errorMsg);
        }
      } else {
        AlertService.serverError(context, "HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      AlertService.error(context, "Something went wrong!");
    } finally {
      isLoading(false);
    }

    // Return the success/failure bool
    return isSuccess;
  }


}
