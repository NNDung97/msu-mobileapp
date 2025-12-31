import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  SocketService._internal();

  IO.Socket? socket;

  void connect(String userId, String token) {
    socket = IO.io(
      'https://msu-nodeserver-production.up.railway.app',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({
            'Authorization': 'Bearer $token',
          })
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print('✅ Socket connected');
      socket!.emit('join', userId);
    });

    socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
    });
  }

  void onNotification(Function(dynamic data) callback) {
    socket?.on('notification:new', callback);
  }

  void disconnect() {
    socket?.disconnect();
  }
}
