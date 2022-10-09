import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

// Enumeracion para manejar los estados del server
enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {
  // ignore: slash_for_doc_comments
  /**
   * Por defecto dejamos con el estado de Connecting, por que la primera vez que
   * se crea la instancia voy a intentar conectarme al servidor.
   */
  ServerStatus _serverStatus = ServerStatus.connecting;
  late io.Socket _socket;

  // Configuramos para que el cambio de status se aplique unicamente aqui
  get serverStatus => _serverStatus;
  io.Socket get socket => _socket;

  // CONSTRUCTOR
  SocketService() {
    _initConfig();
  }

  // METODOS PRIVADOS
  void _initConfig() {
    _socket = io.io('http://192.168.1.5:3000/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.on('connect', (_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });
    // socket.on('event', (data) => print(data));
    _socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });
    // socket.on('fromServer', (_) => print(_));

    // socket.on('nuevo-mensaje', (payload) {
    //   print('nuevo-mensaje: $payload');
    //   print('Nombre:  ' + payload['nombre']);
    //   print('Mensaje: ' + payload['mensaje']);
    //   print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'no hay');
    // });

    /**
     * Lo que podemos ejecutar para probar este ultimo este arroja un 'no hay':
     * socket.emit('emitir-mensaje',{ nombre: 'Cristian', mensaje: 'Hola a todos'});
     * 
     * En este caso arroja el mensaje 2
     * socket.emit('emitir-mensaje',{ nombre: 'Cristian', mensaje: 'Hola a todos',mensaje2: 'Genial!!'});

     */
  }
}
