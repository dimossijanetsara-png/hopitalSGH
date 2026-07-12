import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/core/constants/api_constants.dart';
import 'package:sghl_mobile/core/storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final storage = ref.watch(tokenStorageProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final refreshToken = await storage.getRefreshToken();
            if (refreshToken == null || refreshToken.isEmpty) {
              await storage.clear();
              handler.next(error);
              return;
            }

            final refreshDio = Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );

            final refreshResponse = await refreshDio.post(
              ApiConstants.authRefresh,
              data: {'refresh': refreshToken},
            );

            final newAccessToken =
                refreshResponse.data['access'] as String? ??
                refreshResponse.data['access_token'] as String?;

            final newRefreshToken =
                refreshResponse.data['refresh'] as String? ??
                refreshResponse.data['refresh_token'] as String?;

            if (newAccessToken != null) {
              await storage.saveTokens(
                access: newAccessToken,
                refresh: newRefreshToken ?? refreshToken,
              );

              final retryOptions = error.requestOptions;
              retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

              final retryResponse = await dio.fetch(retryOptions);
              handler.resolve(retryResponse);
              return;
            } else {
              await storage.clear();
            }
          } catch (_) {
            await storage.clear();
          }
        }
        handler.next(error);
      },
    ),
  );

  return ApiClient(dio, storage);
});

class ApiClient {
  final Dio _dio;
  final TokenStorage _storage;

  ApiClient(this._dio, this._storage);

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParams,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
  }) async {
    return _dio.post(path, data: data);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
  }) async {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
  }) async {
    return _dio.delete(path, data: data);
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    return _dio.put(path, data: data);
  }

  TokenStorage get storage => _storage;
}
