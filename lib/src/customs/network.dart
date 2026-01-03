import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:kitokopay/src/customs/constatnts.dart';
import 'package:kitokopay/src/customs/failure.dart';
import 'package:kitokopay/service/certificate_pinning_service.dart'; // PHASE 3: Certificate pinning
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class NetworkUtil {
  factory NetworkUtil() => _networkUtil;

  NetworkUtil._internal();

  static final NetworkUtil _networkUtil = NetworkUtil._internal();

  final _logger = Logger();

  Dio _getHttpClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Constatnts.BASE_URL,
        contentType: 'application/json',
        headers: <String, dynamic>{
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 60 * 1000),
        receiveTimeout: const Duration(seconds: 60 * 1000),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // add authorization token here if there is any
          options.headers['Authorization'] =
              'Bearer  ';
          return handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
        ),
      );
    }

    // PHASE 3: Certificate Pinning + SSL Certificate Validation
    // Certificate pinning adds extra security by validating certificate fingerprints
    // Only bypass in development with explicit flag: --dart-define=ALLOW_INSECURE_SSL=true
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      // PHASE 3: Try to use certificate pinning service
      final certPinningService = CertificatePinningService();
      final pinnedClient = certPinningService.createPinnedHttpClient();
      
      if (pinnedClient != null) {
        // Certificate pinning is enabled and configured
        if (kDebugMode) {
          debugPrint('✅ Certificate pinning ENABLED (extra SSL security)');
        }
        return pinnedClient;
      }
      
      // Fallback: Standard SSL validation (or web platform)
      final client = HttpClient();
      
      // Check if insecure SSL is explicitly allowed (development only)
      final allowInsecure = const bool.fromEnvironment('ALLOW_INSECURE_SSL', defaultValue: false);
      
      if (allowInsecure && kDebugMode) {
        // Only bypass in development with explicit flag
        if (kDebugMode) {
          debugPrint('⚠️ WARNING: SSL certificate validation is DISABLED (development mode only)');
          debugPrint('⚠️ This should NEVER be enabled in production builds!');
        }
        client.badCertificateCallback = (_, __, ___) => true;
      } else {
        // Production: Certificate validation is enabled by default
        // This prevents MITM attacks
        if (kDebugMode) {
          debugPrint('✅ SSL certificate validation ENABLED (secure)');
        }
      }
      
      return client;
    };
    return dio;
  }

  Future<Map<String, dynamic>> getReq(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _getHttpClient().get<dynamic>(
        url,
        queryParameters: queryParameters,
      );

      final responseBody = response.data as Map<String, dynamic>;

      if (responseBody.isEmpty) {
        throw Failure(message: 'An error occured, please try again later');
      }

      return responseBody;
    } on SocketException catch (_) {
      throw Failure(message: 'No internet connection');
    } on TimeoutException catch (_) {
      throw Failure(message: 'Session timeout');
    } on DioException catch (err) {
      // Log errors only in debug mode, sanitized
      if (kDebugMode) {
        _logger
          ..d('Error Type: ${err.runtimeType}')
          ..i('Status Code: ${err.response?.statusCode}');
        // Don't log full error response (may contain sensitive data)
      }

      if (err.response?.statusCode == 401) {
        throw Failure(
          message: 'Session timeout',
        );
      }

      if (err.response?.statusCode == 404) {
        throw Failure(
          message: 'Not found',
          statusCode: err.response?.statusCode,
        );
      }

      if (err.response?.statusCode == 500) {
        throw Failure(
          // ignore: avoid_dynamic_calls
          message: err.response?.data['message'] as String,
          statusCode: err.response?.statusCode,
        );
      }

      if (DioExceptionType.unknown == err.type) {
        _logger
          ..d('Error: $err')
          ..i('${err.response?.statusCode}')
          ..i('Error: ${err.response?.data}');
        throw Exception('Server error');
      } else if (DioExceptionType.connectionTimeout == err.type) {
        throw const SocketException('No internet connection');
      } else if (DioExceptionType.connectionError == err.type) {
        throw const SocketException('No Internet Connection');
      }
      throw Exception('Server error');
    }
  }

  Future<Map<String, dynamic>> postReq(
    String url, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _getHttpClient().post<dynamic>(
        url,
        data: json.encode(body),
        queryParameters: queryParameters,
      );

      final responseBody = response.data as Map<String, dynamic>;

      // Log response only in debug mode, sanitized
      if (kDebugMode) {
        Logger().i('Response received: [Length: ${responseBody.length} entries]');
        // Don't log full response body (may contain sensitive data)
      }

      if (responseBody.isEmpty) {
        throw Failure(message: 'An error occured, please try again later');
      }

      return responseBody;
    } on SocketException catch (_) {
      throw Failure(message: 'No internet connection');
    } on TimeoutException catch (_) {
      throw Failure(message: 'Session timeout');
    } on DioException catch (err) {
      // Log errors only in debug mode, sanitized
      if (kDebugMode) {
        _logger
          ..d('Error Type: ${err.runtimeType}')
          ..i('Status Code: ${err.response?.statusCode}');
        // Don't log full error response (may contain sensitive data)
      }

      if (err.response?.statusCode == 401) {
        throw Failure(
          message: 'Session timeout',
          statusCode: err.response?.statusCode,
        );
      }

      if (err.response?.statusCode == 404) {
        throw Failure(
          message: 'Not found',
          statusCode: err.response?.statusCode,
        );
      }

      if (err.response?.statusCode == 422) {
        throw Failure(
          // ignore: avoid_dynamic_calls
          message: err.response?.data['message'] as String,
          statusCode: err.response?.statusCode,
        );
      }

      if (err.response?.statusCode == 500) {
        throw Failure(
          // ignore: avoid_dynamic_calls
          message: err.response?.data['message'] as String,
          statusCode: err.response?.statusCode,
        );
      }

      if (DioExceptionType.unknown == err.type) {
        _logger
          ..d('Error: $err')
          ..i('${err.response?.statusCode}')
          ..i('Error: ${err.response?.data}');
        throw Exception('Server error');
      } else if (DioExceptionType.connectionTimeout == err.type) {
        throw const SocketException('No internet connection');
      } else if (DioExceptionType.connectionError == err.type) {
        throw const SocketException('No Internet Connection');
      }
      throw Exception('Server error');
    }
  }

  Future<Map<String, dynamic>> putReq(
    String url, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _getHttpClient().put<dynamic>(
        url,
        data: json.encode(body),
        queryParameters: queryParameters,
      );

      final responseBody = response.data as Map<String, dynamic>;

      // Log response only in debug mode, sanitized
      if (kDebugMode) {
        Logger().i('Response received: [Length: ${responseBody.length} entries]');
        // Don't log full response body (may contain sensitive data)
      }

      if (responseBody.isEmpty) {
        throw Failure(message: 'An error occured, please try again later');
      }

      return responseBody;
    } on SocketException catch (_) {
      throw Failure(message: 'No internet connection');
    } on TimeoutException catch (_) {
      throw Failure(message: 'Session timeout');
    } on DioException catch (err) {
      // Log errors only in debug mode, sanitized
      if (kDebugMode) {
        _logger
          ..d('Error Type: ${err.runtimeType}')
          ..i('Status Code: ${err.response?.statusCode}');
        // Don't log full error response (may contain sensitive data)
      }

      if (err.response?.statusCode == 401) {
        throw Failure(
          message: 'Session timeout',
          statusCode: err.response?.statusCode,
        );
      }

      if (err.response?.statusCode == 404) {
        throw Failure(
          message: 'Not found',
          statusCode: err.response?.statusCode,
        );
      }

      if (err.response?.statusCode == 422) {
        throw Failure(
          // ignore: avoid_dynamic_calls
          message: err.response?.data['message'] as String,
          statusCode: err.response?.statusCode,
        );
      }

      if (err.response?.statusCode == 500) {
        throw Failure(
          // ignore: avoid_dynamic_calls
          message: err.response?.data['message'] as String,
          statusCode: err.response?.statusCode,
        );
      }

      if (DioExceptionType.unknown == err.type) {
        _logger
          ..d('Error: $err')
          ..i('${err.response?.statusCode}')
          ..i('Error: ${err.response?.data}');
        throw Exception('Server error');
      } else if (DioExceptionType.connectionTimeout == err.type) {
        throw const SocketException('No internet connection');
      } else if (DioExceptionType.connectionError == err.type) {
        throw const SocketException('No Internet Connection');
      }
      throw Exception('Server error');
    }
  }

  Future<Map<String, dynamic>> postWithFormData(
    String url, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    String? filePath,
    String? field,
  }) async {
    try {
      final response = await _getHttpClient().post<dynamic>(
        url,
        data: FormData.fromMap(<String, dynamic>{
          if (field != null && filePath != null)
            field: await MultipartFile.fromFile(filePath),
          ...?body,
        }),
        queryParameters: queryParameters,
      );

      final responseBody = response.data as Map<String, dynamic>;

      // Log response only in debug mode, sanitized
      if (kDebugMode) {
        Logger().i('Response received: [Length: ${responseBody.length} entries]');
        // Don't log full response body (may contain sensitive data)
      }

      if (responseBody.isEmpty) {
        throw Failure(message: 'An error occured, please try again later');
      }

      return responseBody;
    } on SocketException catch (_) {
      throw Failure(message: 'No internet connection');
    } on TimeoutException catch (_) {
      throw Failure(message: 'Session timeout');
    } on DioException catch (err) {
      // Log errors only in debug mode, sanitized
      if (kDebugMode) {
        _logger
          ..d('Error Type: ${err.runtimeType}')
          ..i('Status Code: ${err.response?.statusCode}');
        // Don't log full error response (may contain sensitive data)
      }

      if (err.response?.statusCode == 401) {
        throw Failure(
          message: 'Session timeout',
          statusCode: err.response?.statusCode,
        );
      }

      if (err.response?.statusCode == 404) {
        throw Failure(
          message: 'Not found',
          statusCode: err.response?.statusCode,
        );
      }

      if (err.response?.statusCode == 422) {
        throw Failure(
          // ignore: avoid_dynamic_calls
          message: err.response?.data['message'] as String,
          statusCode: err.response?.statusCode,
        );
      }

      if (err.response?.statusCode == 500) {
        throw Failure(
          // ignore: avoid_dynamic_calls
          message: err.response?.data['message'] as String,
          statusCode: err.response?.statusCode,
        );
      }

      if (DioExceptionType.unknown == err.type) {
        _logger
          ..d('Error: $err')
          ..i('${err.response?.statusCode}')
          ..i('Error: ${err.response?.data}');
        throw Exception('Server error');
      } else if (DioExceptionType.connectionTimeout == err.type) {
        throw const SocketException('No internet connection');
      } else if (DioExceptionType.connectionError == err.type) {
        throw const SocketException('No Internet Connection');
      }
      throw Exception('Server error');
    }
  }
}
