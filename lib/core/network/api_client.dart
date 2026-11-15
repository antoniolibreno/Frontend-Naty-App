import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import '../error/failure.dart';
import '../auth/authenticated_user.dart';

@lazySingleton
class ApiClient {
  ApiClient(this.config);

  final AppConfig config;
  String? _token;
  AuthenticatedUser? _user;
  AuthenticatedUser? get currentUser => _user;

  void updateCurrentUser(AuthenticatedUser user) {
    if (_user?.userId != null && _user!.userId != user.userId) {
      throw const FormatException('Perfil não pertence à sessão atual.');
    }
    _user = user;
  }

  void setSession(Map<String, dynamic> json) {
    final user = AuthenticatedUser.fromJson(json);
    final token = json['token'] as String;
    _user = user;
    _token = token;
  }

  void setToken(String token) => _token = token;

  void clearToken() {
    _token = null;
    _user = null;
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _send(
      () => http.get(_uri(path), headers: _headers()),
    );
    return _decodeObject(response);
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await _send(
      () => http.get(_uri(path), headers: _headers()),
    );
    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw const UnexpectedFailure('Resposta inválida da API.');
    }
    return decoded;
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _send(
      () => http.post(
        _uri(path),
        headers: _headers(contentType: true),
        body: body == null ? null : jsonEncode(body),
      ),
    );
    return _decodeObject(response);
  }

  Future<void> delete(String path) async {
    await _send(() => http.delete(_uri(path), headers: _headers()));
  }

  Map<String, String> _headers({bool contentType = false}) => {
    if (contentType) 'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Uri _uri(String path) => Uri.parse('${config.baseUrl}$path');

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    late final http.Response response;
    try {
      response = await request().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const NetworkFailure(
        'A API demorou para responder. Verifique se o backend está ativo.',
      );
    } on http.ClientException {
      throw const NetworkFailure(
        'Não foi possível conectar à API. Verifique o backend e o encaminhamento USB.',
      );
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    Map<String, dynamic>? error;
    try {
      error = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      // Mantém a exceção uniforme mesmo quando o servidor não devolve JSON.
    }
    throw ApiFailure(
      status: response.statusCode,
      codigo: error?['codigo'] as String?,
      message:
          error?['mensagem'] as String? ?? 'O servidor recusou a requisição.',
    );
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const UnexpectedFailure('Resposta inválida da API.');
    }
    return decoded;
  }
}
