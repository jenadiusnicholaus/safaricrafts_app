import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';

class ApiService extends GetxService {
  static ApiService get instance => Get.find();

  late dio.Dio _dio;
  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // Request interceptor
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        // Debug: Print the full URL being requested
        if (kDebugMode) {
          print('🌐 Making request to: ${options.baseUrl}${options.path}');
          print('🌐 Full URI: ${options.uri}');
        }

        // Add auth token if available
        final token = _storage.read('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Add device info
        options.headers['X-Device-ID'] =
            _storage.read('device_id') ?? 'unknown';
        options.headers['X-App-Version'] = '1.0.0';

        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));

    // Response interceptor
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onResponse: (response, handler) {
        if (response.statusCode == 401) {
          _handleUnauthorized();
        }
        handler.next(response);
      },
    ));

    // Add logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(dio.LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }
  }

  void setToken(String token) {
    _storage.write('access_token', token);
  }

  void removeToken() {
    _storage.remove('access_token');
  }

  String? getToken() {
    return _storage.read('access_token');
  }

  // GET request
  Future<dio.Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // POST request
  Future<dio.Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // PUT request
  Future<dio.Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // DELETE request
  Future<dio.Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // PATCH request
  Future<dio.Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // File upload
  Future<dio.Response> uploadFile(
    String endpoint,
    String filePath, {
    String fileName = 'file',
    Map<String, dynamic>? additionalData,
    dio.ProgressCallback? onSendProgress,
  }) async {
    try {
      dio.FormData formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(filePath, filename: fileName),
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(dynamic error) {
    // Add safety check - only show snackbars if navigation is ready
    bool canShowSnackbar() {
      try {
        return Get.context != null;
      } catch (e) {
        return false;
      }
    }

    if (error is dio.DioException) {
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
          if (canShowSnackbar()) {
            Get.snackbar(
              'Connection Error',
              'Request timeout. Please check your internet connection.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
          break;
        case dio.DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message =
              error.response?.data?['message'] ?? 'Unknown error occurred';
          final responseData = error.response?.data?.toString() ?? '';

          if (statusCode == 401) {
            _handleUnauthorized();
          } else if (responseData.contains('ALLOWED_HOSTS') ||
              responseData.contains('DisallowedHost')) {
            if (canShowSnackbar()) {
              Get.snackbar(
                'Server Configuration Error',
                'The API server needs to be configured to accept requests from this IP address. Please add the client IP to ALLOWED_HOSTS in Django settings.',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 5),
              );
            }
          } else {
            if (canShowSnackbar()) {
              Get.snackbar(
                'Error $statusCode',
                message,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          }
          break;
        case dio.DioExceptionType.cancel:
          // Request was cancelled, usually no need to show error
          break;
        case dio.DioExceptionType.connectionError:
          if (canShowSnackbar()) {
            Get.snackbar(
              'Network Error',
              'Please check your internet connection and try again.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
          break;
        default:
          if (canShowSnackbar()) {
            Get.snackbar(
              'Error',
              'An unexpected error occurred. Please try again.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
      }
    } else {
      if (canShowSnackbar()) {
        Get.snackbar(
          'Error',
          'An unexpected error occurred: ${error.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void _handleUnauthorized() {
    // Add safety check - only show snackbars and navigate if navigation is ready
    bool canShowSnackbar() {
      try {
        return Get.context != null;
      } catch (e) {
        return false;
      }
    }

    // Only handle unauthorized if we're not in the middle of a login flow
    final isLoginFlow = _storage.read('login_redirect') != null;

    if (!isLoginFlow && canShowSnackbar()) {
      removeToken();
      Get.offAllNamed('/login');
      Get.snackbar(
        'Authentication Error',
        'Your session has expired. Please login again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (!isLoginFlow) {
      // If navigation isn't ready but we need to handle unauthorized, just clear tokens
      removeToken();
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = _storage.read('refresh_token');
      if (refreshToken == null) {
        _handleUnauthorized();
        return false;
      }

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setToken(data['access']);
        return true;
      }

      return false;
    } catch (e) {
      _handleUnauthorized();
      return false;
    }
  }
}
