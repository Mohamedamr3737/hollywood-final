import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../general/consts/consts.dart';
import '../../auth/controller/token_controller.dart';

class SessionController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var errorMessage2 = ''.obs;
  var successMessage = ''.obs;
  // Separate lists for regions and session details
  var regions = <Map<String, dynamic>>[].obs;  // Holds session regions
  var sessionDetails = <Map<String, dynamic>>[].obs;  // Holds details of sessions in a region
  var availableTimes = <Map<String, dynamic>>[].obs;  // Holds available times for a session

  @override
  void onInit() async {
    super.onInit();
    fetchSessions();
  }

  /// **Fetch Available Regions**
  Future<void> fetchSessions() async {
    try {
      isLoading(true);
      var bearerToken= await getAccessToken();
      errorMessage.value = "";

      print("Fetching regions...");

      final response = await http.get(
        Uri.parse("https://portal.ahmed-hussain.com/api/patient/sessions/region"),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData["status"] == true && jsonData["data"] != null) {
          regions.value = List<Map<String, dynamic>>.from(jsonData["data"]);
          print("Regions Fetched: ${regions.length}");
        } else {
          errorMessage.value = "No regions found.";
          print("API Error: ${jsonData['message']}");
        }
      } else {
        errorMessage.value = "HTTP Error: ${response.statusCode}";
        print("HTTP Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      errorMessage.value = "Something went wrong!";
      print("Exception: $e");
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

      print("Fetching session details for region_id: $regionId...");

      final response = await http.get(
        Uri.parse("https://portal.ahmed-hussain.com/api/patient/sessions?region_id=$regionId"),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

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
          print("Sessions in Region $regionId Fetched: ${sessionDetails.length}");
        } else {
          errorMessage2.value = "No sessions found in this region.";
        }
      } else {
        errorMessage2.value = "HTTP Error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage2.value = "Something went wrong!";
      print("Exception: $e");
    } finally {
      isLoading(false);
    }
  }

  /// **Fetch Available Times for a Session**
  Future<void> fetchSessionTimes(int sessionId, String date) async {
    try {
      isLoading(true);
      var bearerToken = await getAccessToken();
      availableTimes.clear();  // Clear old times before fetching new ones

      print("Fetching available times for session_id: $sessionId on date: $date...");

      final response = await http.get(
        Uri.parse("https://portal.ahmed-hussain.com/api/patient/sessions/session-time?session_id=$sessionId&date=$date"),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData["status"] == true && jsonData["data"] != null) {
          availableTimes.value = List<Map<String, dynamic>>.from(jsonData["data"]);
          print("Available Times for Session $sessionId on $date Fetched: ${availableTimes.length}");
        } else {
          print("No available times found for this session on $date.");
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    } finally {
      isLoading(false);
    }
  }

  /// **Clear session details when exiting a region page**
  void clearSessionDetails() {
    sessionDetails.clear();
    print("Session details cleared");
  }

  /// **Clear available times when no longer needed**
  void clearAvailableTimes() {
    availableTimes.clear();
    print("Available times cleared");
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
          "https://portal.ahmed-hussain.com/api/patient/sessions/set-time"
              "?date=$formattedDate&time=$formattedTime&room_id=$roomId&session_id=$sessionId");

      print("📤 Sending request to: $url");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      print("📥 Response Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonData["status"] == true) {
          successMessage.value =
              jsonData["message"] ?? "Time set successfully!";
          VxToast.show(context, msg: successMessage.value);
          print("✅ Success: ${successMessage.value}");
          await fetchSessionDetails(jsonData['data']['region_id']);
          // update(); // ✅ Forces UI Rebuild
          isSuccess=true;
        } else {
          VxToast.show(context, msg: jsonData["message"]["time"][0] ??
              "Failed to set time.");
          print("❌ API Error: ${errorMessage.value}");
        }
      } else {
        VxToast.show(context, msg: "HTTP Error: ${response.statusCode}");
        print("❌ HTTP Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      VxToast.show(context, msg: "Something went wrong!");
      print("❌ Exception: $e");
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
        "https://portal.ahmed-hussain.com/api/patient/sessions/cancel-time?session_id=$sessionId",
      );

      print("📤 Sending request to: $url");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      print("📥 Response Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonData["status"] == true) {
          successMessage.value =
              jsonData["message"] ?? "Time canceled successfully!";
          VxToast.show(context, msg: successMessage.value);
          print("✅ Success: ${successMessage.value}");

          // Refresh session data if needed
          await fetchSessionDetails(jsonData['data']['region_id']);

          // Indicate success
          isSuccess = jsonData['status'];
        } else {
          VxToast.show(context, msg: jsonData["message"] ??
              "Failed to cancel time.");
          print("❌ API Error: ${errorMessage.value}");
        }
      } else {
        VxToast.show(context, msg: "HTTP Error: ${response.statusCode}");
        print("❌ HTTP Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      VxToast.show(context, msg: "Something went wrong!");
      print("❌ Exception: $e");
    } finally {
      isLoading(false);
    }

    // Return the success/failure bool
    return isSuccess;
  }


}
