import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_paths.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._storage)
      : _dio = Dio(BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        )),
        _refreshDio = Dio(BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        )) {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final response = error.response;
          final isUnauthorized = response?.statusCode == 401;
          final alreadyRetried = error.requestOptions.extra['retried'] == true;
          if (!isUnauthorized || alreadyRetried) {
            handler.next(error);
            return;
          }

          final refreshToken = await _storage.getRefreshToken();
          if (refreshToken == null || refreshToken.isEmpty) {
            handler.next(error);
            return;
          }

          try {
            final refreshResponse = await _refreshDio.post<Map<String, dynamic>>(
              ApiPaths.authRefresh,
              data: {'refresh': refreshToken},
            );
            final access = refreshResponse.data?['access']?.toString();
            if (access == null || access.isEmpty) {
              handler.next(error);
              return;
            }
            await _storage.saveAccessToken(access);
            final request = error.requestOptions;
            request.extra['retried'] = true;
            request.headers['Authorization'] = 'Bearer $access';
            final retryResponse = await _dio.fetch<dynamic>(request);
            handler.resolve(retryResponse);
          } catch (_) {
            await _storage.clearTokens();
            handler.next(error);
          }
        },
      ),
    );
  }

  final Dio _dio;
  final Dio _refreshDio;
  final SecureStorageService _storage;

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch<dynamic>(path, data: data);
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete<dynamic>(path, data: data);
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
