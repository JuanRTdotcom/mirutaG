import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:pie_chart/pie_chart.dart';
import 'package:d_chart/d_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miruta/lista_de_pantalla.dart';

class Billetera extends StatefulWidget {
  const Billetera({Key? key}) : super(key: key);

  @override
  State<Billetera> createState() => _BilleteraState();
}

final dataMap = <String, double>{"Saldo disponible": 70};

final colorList = <Color>[
  Colors.amber,
  const Color.fromARGB(255, 191, 191, 191).withOpacity(0.15)
];

class _BilleteraState extends State<Billetera> {
  List misMovimientos = [];
  double saldoTotal = 0, saldoUtil = 0;
  String saldoTotalS = '', saldoUtilS = '';
  bool buscandoSaldo = false,
      buscandoMovimientos = false,
      recargandoSaldo = false;

  Future<dynamic> recargarSaldo() async {
    setState(() {
      recargandoSaldo = true;
    });
    const storage = FlutterSecureStorage();
    String? value = await storage.read(key: 'SESSION');
    Map<String, dynamic> usuarioResponse = json.decode(value ?? '');
    dynamic idChofer = usuarioResponse['iIdChofer'];
    dynamic miSaldoNuevo = await Lib().recargarSaldo(int.parse(idChofer), 50);
    setState(() {
      recargandoSaldo = false;
    });
    return miSaldoNuevo;
  }

  Future<void> listarSaldo() async {
    setState(() {
      buscandoSaldo = true;
    });
    const storage = FlutterSecureStorage();
    String? value = await storage.read(key: 'SESSION');
    Map<String, dynamic> usuarioResponse = json.decode(value ?? '');
    dynamic idChofer = usuarioResponse['iIdChofer'];
    dynamic miSaldoNuevo = await Lib().listarSaldo(int.parse(idChofer));
    print(miSaldoNuevo);
    if(mounted){
      setState(() {
        saldoTotal = double.parse(miSaldoNuevo[0]['mTotal']);
        saldoUtil = double.parse(miSaldoNuevo[0]['mSaldo']);
        saldoTotalS = miSaldoNuevo[0]['mTotal'];
        saldoUtilS = miSaldoNuevo[0]['mSaldo'];
        buscandoSaldo = false;
      });

    }
  }

  Future<void> listarMovimientosSaldo() async {
    setState(() {
      buscandoMovimientos = true;
    });
    const storage = FlutterSecureStorage();
    String? value = await storage.read(key: 'SESSION');
    Map<String, dynamic> usuarioResponse = json.decode(value ?? '');
    dynamic idChofer = usuarioResponse['iIdChofer'];
    dynamic miSaldoNuevo =
        await Lib().listarmovimientosSaldo(int.parse(idChofer));
    setState(() {
      misMovimientos = miSaldoNuevo;
      buscandoMovimientos = false;
    });
  }

  String convertirHora(String fecha) {
    List misMeses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    String miMes = misMeses[int.parse(fecha.substring(5, 7)) - 1];
    String midia = fecha.substring(8, 10);
    return '$midia de $miMes';
  }

  @override
  void initState() {
    listarMovimientosSaldo();
    listarSaldo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          dynamic misaldo = await recargarSaldo();
          listarSaldo();
          listarMovimientosSaldo();
          print('depositao $misaldo');
        },
        label: recargandoSaldo
            ? const Text('Depositando...')
            : const Text('Depositar'),
        icon: const Icon(Icons.credit_card_rounded),
        backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
      ),
      appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
          centerTitle: true,
          title: const Text('Mi Billetera',style: TextStyle(fontSize: 14),),
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 16,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          })),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Stack(children: [
            Center(
              child: SizedBox(
                height: 220,
                child: buscandoSaldo
                    ? const CupertinoActivityIndicator()
                    : DChartGauge(
                        data: [
                          {'domain': saldoUtilS, 'measure': saldoUtil},
                          {
                            'domain': (saldoTotal - saldoUtil).toString(),
                            'measure': saldoTotal - saldoUtil
                          },
                        ],
                        fillColor: (pieData, index) {
                          switch (index) {
                            case 0:
                              return Colors.amber;
                            default:
                              return const Color.fromARGB(255, 233, 233, 233);
                          }
                        },
                        donutWidth: 20,
                        showLabelLine: false,
                        pieLabel: (pieData, index) {
                          return "${pieData['domain']}";
                        },
                        labelPosition: PieLabelPosition.outside,
                        labelPadding: 0,
                        labelColor: const Color.fromRGBO(21, 21, 21, 1),
                      ),
              ),
            ),
            buscandoSaldo
                ? const Text('')
                : SizedBox(
                    height: 220,
                    child: Center(
                      child: Text(
                        saldoTotalS,
                        style: const TextStyle(
                            color: Color.fromRGBO(21, 21, 21, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
          ]),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Colors.amber,
                        width: 10,
                        height: 10,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('Saldo')
                  ],
                ),
                const SizedBox(
                  width: 30,
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: const Color.fromARGB(255, 233, 233, 233),
                        width: 10,
                        height: 10,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('Gastado')
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Movimientos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: buscandoMovimientos
                ? const CupertinoActivityIndicator()
                : ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                      height: 1,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: misMovimientos.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.all(0),

                          title: const Text('Depósito',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            convertirHora(
                                misMovimientos[index]['dFechaRegistro']),
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 10),
                          ),
                          // leading: const Icon(Icons.payments_rounded),
                          trailing: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              color: const Color.fromRGBO(21, 21, 21, 1),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'S/ +${misMovimientos[index]['mMontoRecarga']}',
                                  style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
