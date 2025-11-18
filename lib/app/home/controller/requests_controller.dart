// requests_controller.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../auth/controller/token_controller.dart';
import 'package:s_medi/general/consts/consts.dart';

class RequestsController {
  // GET /api/patient/my-requests/categories
  Future<List<dynamic>> fetchCategories() async {
    final bearerToken = await getAccessToken();
    final url = "${ApiConfig.baseUrl}/api/patient/my-requests/categories";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      // The "type" array is at jsonData['data']['type']
      final typeArray = jsonData['data']['type'] as List<dynamic>;
      // Each item looks like { "id": 1, "title": "Appointment" }
      return typeArray;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // GET /api/patient/my-requests/list?type=<typeId>
  Future<List<dynamic>> fetchMyRequests(int typeId) async {
    final bearerToken = await getAccessToken();
    final url = "${ApiConfig.baseUrl}/api/patient/my-requests/list?type=$typeId";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      // "data" is the array of requests
      return jsonData['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load my requests (status: ${response.statusCode})');
    }
  }

  // POST /api/patient/my-requests/comment/create
  // Sends ticket_id, comment, and optional file (files[])
  Future<Map<String, dynamic>> addComment({
    required String ticketId,
    required String commentText,
    String? filePath,
  }) async {
    final bearerToken = await getAccessToken();
    final url = "${ApiConfig.baseUrl}/api/patient/my-requests/comment/create";

    // Create a multipart request
    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $bearerToken'
      ..fields['ticket_id'] = ticketId
      ..fields['comment'] = commentText;

    // If user selected a file, attach it as files[]
    if (filePath != null) {
      final file = File(filePath);
      final fileName = file.path.split('/').last; // e.g. "document.pdf"

      request.files.add(
        await http.MultipartFile.fromPath(
          'files[]',
          file.path,
          filename: fileName,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (jsonData['status'] == true) {
        // The server returns { "data": { ... }, "status": true, "message": "" }
        return jsonData; // e.g. { "data": {...}, "status":true, "message":"" }
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to add comment');
      }
    } else {
      throw Exception('Failed to add comment (status: ${response.statusCode})');
    }
  }

  // POST /api/patient/my-requests/close
  // Body: { "ticket_id": <int> }
  Future<Map<String, dynamic>> closeTicket(int ticketId) async {
    final bearerToken = await getAccessToken();
    final url = "${ApiConfig.baseUrl}/api/patient/my-requests/close";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({"ticket_id": ticketId}), // Send ticket_id as JSON
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      // Usually returns { "data": {...}, "status": true, ... }
      if (jsonData['status'] == true) {
        return jsonData; // The updated ticket is in jsonData['data']
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to close ticket');
      }
    } else {
      throw Exception('Failed to close ticket (status: ${response.statusCode})');
    }
  }

  // POST /api/patient/my-requests/create
  // Body: type_id, subject, description, files[]
  Future<Map<String, dynamic>> createTicket({
    required int typeId,
    required String subject,
    required String description,
    List<String>? filePaths, // optional
  }) async {
    final bearerToken = await getAccessToken();
    final url = "${ApiConfig.baseUrl}/api/patient/my-requests/create";

    // We'll use a MultipartRequest for file uploads
    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $bearerToken'
      ..fields['type_id'] = typeId.toString()
      ..fields['subject'] = subject
      ..fields['description'] = description;

    // If we have any file paths, attach them
    if (filePaths != null && filePaths.isNotEmpty) {
      for (final path in filePaths) {
        final file = File(path);
        final fileName = file.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'files[]',
            file.path,
            filename: fileName,
          ),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (jsonData['status'] == true) {
        // The new ticket is in jsonData['data']
        return jsonData;
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to create ticket');
      }
    } else {
      throw Exception('Failed to create ticket (status: ${response.statusCode})');
    }
  }
}
