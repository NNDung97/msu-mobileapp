import 'package:dio/dio.dart';

import '../service/auth_storage.dart';
import '../network/api_client.dart';
import '../navigation/app_navigator.dart';

class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<Future<void> Function()> _queue = [];

  final Dio _refreshDio = Dio(
    BaseOptions(baseUrl: 'https://msu-nodeserver-production.up.railway.app/api'),
  );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await AuthStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Không phải 401 → bỏ qua
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // ❌ Nếu refresh-token bị 401 → logout cứng
    if (err.requestOptions.path.contains('/auth/refresh-token')) {
      await _forceLogout(handler, err);
      return;
    }

    // Nếu đang refresh → đưa request vào queue
    if (_isRefreshing) {
      _queue.add(() async {
        final token = await AuthStorage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        handler.resolve(await ApiClient.dio.fetch(err.requestOptions));
      });
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await AuthStorage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token');
      }

      final response = await _refreshDio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];

      await AuthStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      _isRefreshing = false;

      // Retry các request đang chờ
      for (final cb in _queue) {
        await cb();
      }
      _queue.clear();

      // Retry request hiện tại
      err.requestOptions.headers['Authorization'] =
          'Bearer $newAccessToken';

      handler.resolve(await ApiClient.dio.fetch(err.requestOptions));
    } catch (_) {
      await _forceLogout(handler, err);
    }
  }

  /// ❗ Logout cứng – không cần Provider
  Future<void> _forceLogout(
    ErrorInterceptorHandler handler,
    DioException err,
  ) async {
    _isRefreshing = false;
    _queue.clear();

    // 1. Clear toàn bộ token
    await AuthStorage.clear();

    // 2. Reset navigation (AuthProvider sẽ sync lại ở app start)
    AppNavigator.goHomeAndReset();

    handler.reject(err);
  }
}
