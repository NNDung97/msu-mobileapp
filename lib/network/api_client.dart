// lib/network/api_client.dart
import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://msu-nodeserver-production.up.railway.app/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(AuthInterceptor());
}
