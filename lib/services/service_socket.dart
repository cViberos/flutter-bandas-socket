import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// Enumeracion para manejar los estados del server
enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  // ignore: slash_for_doc_comments
  /**
   * Por defecto dejamos con el estado de Connecting, por que la primera vez que
   * se crea la instancia voy a intentar conectarme al servidor.
   */
  ServerStatus _serverStatus = ServerStatus.Connecting;
  // Configuramos para que el cambio de status se aplique unicamente aqui
  get serverStatus => _serverStatus;

  // CONSTRUCTOR
  SocketService() {
    _initConfig();
  }

  // METODOS PRIVADOS
  void _initConfig() {
    IO.Socket socket = IO.io('http://192.168.1.5:3000/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.on('connect', (_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    // socket.on('event', (data) => print(data));
    socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
    // socket.on('fromServer', (_) => print(_));
  }
}
