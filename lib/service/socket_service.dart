import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  String? _userId;
  String? _token;

  void connect(String userId, String token) {
    _userId = userId;
    _token = token;

    if (_socket != null && _socket!.connected) {
      print('🔁 Socket already connected');
      return;
    }

    _socket?.dispose();

    _socket = IO.io(
      'https://msu-nodeserver-production.up.railway.app',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999)
          .setReconnectionDelay(2000)
          .setExtraHeaders({
            'Authorization': 'Bearer $token',
          })
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Socket connected');
      _socket!.emit('join', _userId);
    });

    _socket!.onReconnect((_) {
      print('🔄 Socket reconnected');
      _socket!.emit('join', _userId);
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
    });

    _socket!.onConnectError((err) {
      print('❌ Socket connect error: $err');
    });
  }

  void onNotification(Function(dynamic data) callback) {
    _socket?.off('notification:new');
    _socket?.on('notification:new', callback);
  }

  void onReconnect(Function() callback) {
    _socket?.off('reconnect');
    _socket?.onReconnect((_) => callback());
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
