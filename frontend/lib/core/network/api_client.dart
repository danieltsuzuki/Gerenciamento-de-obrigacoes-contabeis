import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/app_config.dart';
import 'api_exception.dart';
import 'downloaded_file.dart';

class ApiClient {
  final http.Client _httpClient;
  final String? _baseUrlOverride;
  String? _authToken;

  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrlOverride = baseUrl;

  String get baseUrl => _baseUrlOverride ?? AppConfig.instance.apiBaseUrl;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  String? get authToken => _authToken;

  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final urlString = '$baseUrl$cleanPath';

    if (queryParameters == null || queryParameters.isEmpty) {
      return Uri.parse(urlString);
    }

    final sanitizedParams = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value != null) {
        sanitizedParams[key] = value.toString();
      }
    });

    return Uri.parse(urlString).replace(queryParameters: sanitizedParams);
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    try {
      final response = await _httpClient
          .get(uri, headers: _buildHeaders(headers))
          .timeout(AppConfig.instance.connectTimeout);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    try {
      final response = await _httpClient
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.instance.connectTimeout);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    try {
      final response = await _httpClient
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.instance.connectTimeout);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkError(e);
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    try {
      final response = await _httpClient
          .patch(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.instance.connectTimeout);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    try {
      final response = await _httpClient
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(AppConfig.instance.connectTimeout);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkError(e);
    }
  }

  Future<dynamic> multipartRequest(
    String path, {
    required String fieldName,
    required String filename,
    required List<int> bytes,
    String? contentType,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    try {
      final request = http.MultipartRequest('POST', uri);

      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      request.headers['Accept'] = 'application/json';
      if (headers != null) {
        request.headers.addAll(headers);
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      MediaType? parsedMediaType;
      if (contentType != null && contentType.isNotEmpty) {
        try {
          parsedMediaType = MediaType.parse(contentType);
        } catch (_) {}
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: parsedMediaType,
        ),
      );

      final streamedResponse = await _httpClient
          .send(request)
          .timeout(AppConfig.instance.connectTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkError(e);
    }
  }

  Future<DownloadedFile> download(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    try {
      final requestHeaders = <String, String>{};
      if (_authToken != null) {
        requestHeaders['Authorization'] = 'Bearer $_authToken';
      }
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      final response = await _httpClient
          .get(uri, headers: requestHeaders)
          .timeout(AppConfig.instance.connectTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final filename = DownloadedFile.extractFilenameFromHeader(
          response.headers['content-disposition'],
        );
        return DownloadedFile(
          filename: filename,
          bytes: response.bodyBytes,
          contentType: response.headers['content-type'] ?? 'application/octet-stream',
        );
      }

      final decodedBody = _parseResponseBody(response);
      if (decodedBody is Map<String, dynamic>) {
        throw ApiException.fromResponse(response.statusCode, decodedBody);
      }
      throw ApiException.fromResponse(response.statusCode, null);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.networkError(e);
    }
  }

  dynamic _processResponse(http.Response response) {
    final decodedBody = _parseResponseBody(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    if (decodedBody is Map<String, dynamic>) {
      throw ApiException.fromResponse(response.statusCode, decodedBody);
    }

    throw ApiException.fromResponse(response.statusCode, null);
  }

  dynamic _parseResponseBody(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return null;
      }
    }
  }
}
