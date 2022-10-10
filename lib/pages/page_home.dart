import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flu_band_names/models/band.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import '../services/service_socket.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  // LISTENERS
  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('La banda más piola'),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.online)
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green[400],
                    size: 30,
                  )
                : Icon(
                    Icons.offline_bolt_rounded,
                    color: Colors.red[300],
                    size: 30,
                  ),
          )
        ],
      ),
      body: Column(
        children: [
          bands.isNotEmpty ? _showGraph() : Container(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (_, i) => _bandTile(bands[i]),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: const Text(
                'Desarrollado por Cristian Gustavo Viberos\nSalta - Argentina, 10/10/2022'),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: socketService.serverStatus == ServerStatus.online
            ? addNewBand
            : null,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      // Borramos la banda seleccionada
      onDismissed: (_) =>
          socketService.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: const EdgeInsets.only(left: 10.0),
        color: Colors.red[400],
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: const [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              Text(
                'Borrar banda',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        // Votamos la banda seleccionada
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Nuevo nombre de banda:'),
          content: TextField(
            controller: textController,
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 5,
              onPressed: () => addBandToList(textController.text),
              child: const Text('Agregar'),
            ),
          ],
        ),
      );
    } else if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Nuevo nombre de banda:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Agregar'),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (name.length > 1) {
      // Agregamos una nueva banda
      socketService.socket.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  Widget _showGraph() {
    // Map<String, double> dataMap = {
    //   "Flutter": 5,
    //   "React": 3,
    //   "Xamarin": 2,
    //   "Ionic": 2,
    // };
    Map<String, double> dataMap = {};
    for (var band in bands) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }

    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 250,
      child: PieChart(
        // Datos usados en la gráfica
        dataMap: dataMap,
        // Animacion del gráfico
        animationDuration: const Duration(milliseconds: 800),
        // Espacio entre el gráfico y la tabla de contenidos
        chartLegendSpacing: 50,
        // Determina el tamaño del gráfico
        chartRadius: MediaQuery.of(context).size.width / 2.2,
        // Lista de colores para usar en las representaciones graficas
        // colorList: colorList,
        // Rotación del gráfico
        initialAngleInDegree: 0,
        // Determina el tipo de graficos(anillo o torta)
        chartType: ChartType.ring,
        // Determina el ancho del gráfico se nota mas si se usa el tipo anillo
        ringStrokeWidth: 38,
        // centerText: "Texto centro del grafico",
        legendOptions: const LegendOptions(
          // Determina si la tabla de referencias será vertical u horizontal
          showLegendsInRow: false,
          // Determina la posición de la tabla de referencias
          legendPosition: LegendPosition.right,
          // Muestra o no la tabla de referencias
          showLegends: true,
          // Estilo de las viñertas de las referencias
          legendShape: BoxShape.circle,
          // Definimos el estilo de texto de las referencias
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          // Agrega una cuadrito de fondo abajo de cada valor en el gráfico
          showChartValueBackground: true,
          // Muestra los valores en la gráfica
          showChartValues: true,
          // Muestra los valores en porcentajes
          showChartValuesInPercentage: false,
          // Ubicar valores en el borde interno o externo del gráfico
          showChartValuesOutside: true,
          // Mostrar gráficos con valores decimales
          decimalPlaces: 0,
        ),
      ),
    );
  }
}
