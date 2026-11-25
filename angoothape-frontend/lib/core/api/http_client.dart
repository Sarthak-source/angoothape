import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_exception.dart';

const apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://localhost:8080',
);

/// Shared HTTP + token storage only. Endpoint methods live in feature `*_api.dart` files.
class HttpClient {
  HttpClient({
    http.Client? httpClient,
    this.baseUrl = apiBase,
    FlutterSecureStorage? storage,
  }) : _http = httpClient ?? http.Client(),
       _storage =
           storage ??
           const FlutterSecureStorage(
             aOptions: AndroidOptions(encryptedSharedPreferences: true),
             iOptions: IOSOptions(
               accessibility: KeychainAccessibility.first_unlock_this_device,
             ),
           );

  final http.Client _http;
  final FlutterSecureStorage _storage;
  final String baseUrl;
  String? token;
  String? mfaToken;

  static const _tokenKey = 'ap_token';
  static const _mfaKey = 'ap_mfa_token';

  bool get hasAccessToken => token != null && token!.isNotEmpty;

  Future<void> restore() async {
    token = await _storage.read(key: _tokenKey);
    mfaToken = await _storage.read(key: _mfaKey);
    if (token != null && token!.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_tokenKey);
    if (legacy == null || legacy.isEmpty) return;
    token = legacy;
    await persistToken(legacy);
    await prefs.remove(_tokenKey);
  }

  Future<void> persistToken(String value, {String? mfa}) async {
    token = value;
    await _storage.write(key: _tokenKey, value: value);
    if (mfa != null && mfa.isNotEmpty) {
      mfaToken = mfa;
      await _storage.write(key: _mfaKey, value: mfa);
    }
  }

  Future<void> clearToken() async {
    token = null;
    mfaToken = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _mfaKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) {
    return _send('GET', path, query: query);
  }

  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> patch(
    String path, [
    Map<String, dynamic>? body,
  ]) {
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
      if (mfaToken != null && mfaToken!.isNotEmpty) 'X-MFA-Token': mfaToken!,
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
