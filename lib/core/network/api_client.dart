import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_config.dart';
import 'api_exception.dart';

enum HttpMethod { get, post, put, delete }

extension HttpMethodX on HttpMethod {
  String get value {
    switch (this) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.delete:
        return 'DELETE';
    }
  }
}

abstract class ApiEndpoint {
  String get baseUrl;
  String get path;
  HttpMethod get method;
  Map<String, String>? get headers;
  Map<String, dynamic>? get queryParameters;
  dynamic get body;
}

abstract class NetworkService {
  Future<T> request<T>(ApiEndpoint endpoint, T Function(dynamic json) decoder);
}

class DefaultNetworkService implements NetworkService {
  DefaultNetworkService({Dio? dio}) : _dio = dio ?? _buildDio();

  final Dio _dio;

  @override
  Future<T> request<T>(
    ApiEndpoint endpoint,
    T Function(dynamic json) decoder,
  ) async {
    final uri = _buildUri(endpoint.baseUrl, endpoint.path);
    final options = Options(
      method: endpoint.method.value,
      headers: _mergeHeaders(endpoint.headers),
      responseType: ResponseType.json,
    );

    final response = await _dio.request(
      uri.toString(),
      data: endpoint.body,
      options: options,
      queryParameters: endpoint.queryParameters,
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw ApiException(
        message: _stringifyError(response.data),
        statusCode: statusCode,
      );
    }

    final data = _normalizeResponseData(response.data);
    return decoder(data);
  }

  Uri _buildUri(String baseUrl, String path) {
    final base = Uri.parse(baseUrl);
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return base.replace(path: normalizedPath);
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    final merged = <String, String>{'x-access-key': ApiConfig.accessKey};
    if (headers != null) {
      merged.addAll(headers);
    }
    return merged;
  }

  dynamic _normalizeResponseData(dynamic data) {
    if (data is String && data.isNotEmpty) {
      try {
        return json.decode(data);
      } catch (_) {
        return data;
      }
    }
    return data;
  }

  String _stringifyError(dynamic data) {
    if (data == null) {
      return 'Unknown error';
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    try {
      return json.encode(data);
    } catch (_) {
      return 'Unknown error';
    }
  }

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    if (kDebugMode) {
      final adapter = IOHttpClientAdapter();
      adapter.onHttpClientCreate = (client) {
        client.badCertificateCallback =
            (cert, host, port) => host == ApiConfig.baseUrlHost;
        return client;
      };
      dio.httpClientAdapter = adapter;
    }
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
    return dio;
  }
}
