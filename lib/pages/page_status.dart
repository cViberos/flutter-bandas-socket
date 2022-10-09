import 'package:flu_band_names/services/service_socket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    // socketService.socket.emit();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Server status: ${socketService.serverStatus}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: () {
          socketService.socket.emit('emitir-mensaje',
              {'nombre': 'Flutter', 'mensaje': 'Hola desde Flutter'});
        },
      ),
    );
  }
}
