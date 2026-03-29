import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // debugPrint ke liye

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    debugPrint("📡 [ApiClient] GET Request: $path | Params: $queryParameters");

    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      debugPrint("✅ [ApiClient] Response Success: ${response.statusCode} | Data size: ${response.data.length}");
      return response;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      debugPrint("[ApiClient] Request Failed: $errorMessage");
      throw errorMessage;
    } catch (e) {
      debugPrint(" [ApiClient] Unexpected Exception: $e");
      throw "An unexpected error occurred.";
    }
  }

  String _handleDioError(DioException error) {
    debugPrint("🛑 [ApiClient] Detailed DioError: Type=${error.type}, Message=${error.message}");

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout with API server";
      case DioExceptionType.receiveTimeout:
        return "Receive timeout in connection with API server";
      case DioExceptionType.badResponse:
        return "Server error: ${error.response?.statusCode}";
      default:
        return "Network connection issue. Please check your internet.";
    }
  }
}