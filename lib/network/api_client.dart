// lib/network/api_client.dart
import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:3000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(AuthInterceptor());
}
