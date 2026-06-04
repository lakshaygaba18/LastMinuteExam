import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ExamApiService {
  static const String uploadUrl =
      'https://exam-engine-backend.onrender.com/file/upload';

  // Track active request so we can cancel if user navigates away
  static http.Client? _activeClient;

  static void cancelActiveRequest() {
    _activeClient?.close();
    _activeClient = null;
  }

  static Future<Map<String, dynamic>> uploadFile(
    File file, {
    void Function(String status)? onStatusUpdate,
  }) async {
    // Cancel any previous in-flight request
    cancelActiveRequest();
    _activeClient = http.Client();

    try {
      // Notify UI we're waking the server
      onStatusUpdate?.call("Connecting to server...");

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(uploadUrl),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      // Send via the tracked client
      final streamedResponse = await _activeClient!
          .send(request)
          .timeout(
            const Duration(seconds: 300),
            onTimeout: () => throw Exception(
              "Request timed out. The server may be starting up — please try again.",
            ),
          );

      onStatusUpdate?.call("Processing your file...");

      final responseBody =
          await streamedResponse.stream.bytesToString();

      print("STATUS: ${streamedResponse.statusCode}");
      print("BODY: $responseBody");

      if (streamedResponse.statusCode != 200) {
        throw Exception(
          "Server error ${streamedResponse.statusCode}: $responseBody",
        );
      }

      final decoded = jsonDecode(responseBody);

      // Backend returns the map directly — no "data" wrapper
      if (decoded is Map<String, dynamic>) {
        // Validate the response actually has questions before returning
        if (decoded.containsKey('error')) {
          throw Exception("Backend error: ${decoded['error']}");
        }
        if (!decoded.containsKey('objective') &&
            !decoded.containsKey('subjective')) {
          throw Exception("Unexpected response format: $decoded");
        }
        return decoded;
      }

      throw Exception("Invalid response format: expected a JSON object");

    } catch (e) {
      rethrow;
    } finally {
      _activeClient = null;
    }
  }
}