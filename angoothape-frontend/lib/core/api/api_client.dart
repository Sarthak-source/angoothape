import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://localhost:8080',
);

class ApiException implements Exception {
  ApiException(this.status, this.code, this.message);
  final int status;
  final String code;
  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? httpClient, this.baseUrl = apiBase})
    : _http = httpClient ?? http.Client();

  final http.Client _http;
  final String baseUrl;
  String? token;

  static const _tokenKey = 'ap_token';

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);
  }

  Future<void> persistToken(String value) async {
    token = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, value);
  }

  Future<void> clearToken() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) {
    return _send('GET', path, query: query);
  }

  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> patch(String path, [Map<String, dynamic>? body]) {
    return _send('PATCH', path, body: body);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    http.Response res;
    try {
      if (method == 'GET') {
        res = await _http.get(uri, headers: headers);
      } else if (method == 'PATCH') {
        res = await _http.patch(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      } else {
        res = await _http.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      }
    } catch (_) {
      throw ApiException(
        0,
        'network',
        'Cannot reach the server. Is the API running?',
      );
    }
    Map<String, dynamic> json = {};
    if (res.body.isNotEmpty) {
      try {
        json = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        json = {'message': res.body};
      }
    }
    if (res.statusCode >= 400) {
      throw ApiException(
        res.statusCode,
        json['error'] as String? ?? 'error',
        json['message'] as String? ?? 'Request failed',
      );
    }
    return json;
  }
}
