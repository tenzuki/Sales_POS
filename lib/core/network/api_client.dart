import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://142.93.214.133:3641/api';
  
  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // POST operation
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    if (kDebugMode) {
      print('HTTP POST: $url');
      print('Payload: ${jsonEncode(body)}');
    }

    http.Response response;
    try {
      response = await _client
          .post(
            url,
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      if (kDebugMode) {
        print('HTTP Error in POST $endpoint: $e');
      }
      throw Exception('Network error. Please check your internet connection.');
    }

    return _handleResponse(response);
  }

  // GET operation with optional JSON body (some APIs in Laravel support GET with JSON body)
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    if (kDebugMode) {
      print('HTTP GET: $url');
      if (body != null) {
        print('GET Payload: ${jsonEncode(body)}');
      }
    }

    http.Response httpResponse;
    try {
      final response = await http.Request('GET', url)
        ..headers.addAll(_headers)
        ..body = body != null ? jsonEncode(body) : '';
      
      final streamedResponse = await _client.send(response).timeout(const Duration(seconds: 30));
      httpResponse = await http.Response.fromStream(streamedResponse);
    } catch (e) {
      if (kDebugMode) {
        print('HTTP Error in GET $endpoint: $e');
      }
      throw Exception('Network error. Please check your internet connection.');
    }

    return _handleResponse(httpResponse);
  }

  // Helper response parser
  dynamic _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;
    final String body = response.body;

    if (kDebugMode) {
      print('HTTP Response ($statusCode): ${body.length > 500 ? "${body.substring(0, 500)}..." : body}');
    }

    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    } else {
      Map<String, dynamic>? errorJson;
      try {
        errorJson = jsonDecode(body);
      } catch (_) {}
      
      String message = 'An error occurred (${response.statusCode})';
      if (errorJson != null) {
        if (errorJson['message'] != null) {
          message = errorJson['message'];
        } else if (errorJson['messages'] != null && errorJson['messages'] is List) {
          message = (errorJson['messages'] as List).join(', ');
        }
      }
      throw Exception(message);
    }
  }
}
