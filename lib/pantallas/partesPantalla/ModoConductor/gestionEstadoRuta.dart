import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miruta/lista_de_pantalla.dart';

class GestionEstadoRuta extends StatefulWidget {
  final String nombreViaje;
  final String distancia;
  final String tiempo;
  final String precio;
  final String idRuta;

  const GestionEstadoRuta(
      {Key? key,
      required this.nombreViaje,
      required this.distancia,
      required this.tiempo,
      required this.precio,
      required this.idRuta})
      : super(key: key);

  @override
  State<GestionEstadoRuta> createState() => _GestionEstadoRutaState();
}

class _GestionEstadoRutaState extends State<GestionEstadoRuta> {
  TextEditingController asientosRutaController = TextEditingController();
  String fechahoraSalida = 'Fecha y hora de salida';
  String valorFechahoraSalida = '';
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

    String miAnio = fecha.substring(0, 4);
    String miMes = misMeses[int.parse(fecha.substring(5, 7)) - 1];
    String midia = fecha.substring(8, 10);
    String miHoras = fecha.substring(11, 13);
    String miMinutos = fecha.substring(14, 16);
    if (int.parse(miHoras) >= 12) {
      var acc = '';
      var miAc = int.parse(miHoras) - 12;

      if (miAc.toString().length == 1) {
        acc = '0${miAc.toString()}';
      } else {
        acc = '$miAc';
      }
      miHoras = acc + ':' + miMinutos + ' p.m';
      if (miAc == 0) {
        miHoras = '00' ':' + miMinutos + ' p.m';
      }
    } else {
      miHoras = miHoras + ':' + miMinutos + ' a.m';
    }

    return '$midia de $miMes, $miAnio - $miHoras';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
          // title: const Text('AppBar Demo'),

          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
              ),
              onPressed: () => Navigator.of(context).pop(),
            );
          })),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      widget.nombreViaje,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.grey),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 14),
                  //   child: Text(ubicacionViaje, style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 10,color: Color.fromARGB(255, 188, 188, 188)),),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Distancia',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Clan'),
                          ),
                          Text(
                            widget.distancia,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(21, 21, 21, 1),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Clan'),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Tiempo',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Clan'),
                          ),
                          Text(
                            widget.tiempo,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(21, 21, 21, 1),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Clan'),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Asientos',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Clan'),
                          ),
                          Text(
                            '0/0',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(21, 21, 21, 1),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Clan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Al dar inicio al viaje ' +
                  widget.nombreViaje +
                  ', se en las búsquedas para que cualquier pasajero pueda enviarte ofertas para adquirir los asientos.',
              style: const TextStyle(
                  color: Color.fromARGB(255, 142, 142, 142),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Clan'),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8), topLeft: Radius.circular(8)),
              child: Container(
                color: const Color.fromRGBO(34, 34, 34, 1),
                child: const Padding(
                  padding:
                      EdgeInsets.only(top: 6, right: 10, bottom: 5, left: 10),
                  child: Text('Nro de asientos',
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromRGBO(34, 34, 34, 1),
                  width: 1,
                ),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(0),
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              child: TextField(
                controller: asientosRutaController,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                    fillColor: Colors.white,
                    hintText: "Cantidad de sientos habilitados",
                    hintStyle: TextStyle(color: Colors.grey)),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8), topLeft: Radius.circular(8)),
              child: Container(
                color: const Color.fromRGBO(34, 34, 34, 1),
                child: const Padding(
                  padding:
                      EdgeInsets.only(top: 6, right: 10, bottom: 5, left: 10),
                  child: Text('Fecha y hora de salida',
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromRGBO(34, 34, 34, 1),
                  width: 1,
                ),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(0),
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              child: TextButton(
                  onPressed: () {
                    DatePicker.showDateTimePicker(context,
                        currentTime: DateTime.now(), showTitleActions: true,
                        // minTime: DateTime(2020, 5, 5, 20, 50),
                        // maxTime: DateTime(2020, 6, 7, 05, 09),

                        // onChanged: (date) {
                        // print('change $date in time zone ' +
                        //     date.timeZoneOffset.inHours.toString());
                        // },
                        onConfirm: (date) {
                      setState(() {
                        valorFechahoraSalida = '$date';
                        fechahoraSalida = convertirHora('$date');
                      });
                      // print('confirm $date');
                    }, locale: LocaleType.es);
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 6, right: 5, bottom: 5, left: 5),
                        child: valorFechahoraSalida == ''
                            ? Text(
                                fechahoraSalida,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              )
                            : Text(
                                fechahoraSalida,
                                style: const TextStyle(
                                    color: Color.fromRGBO(34, 34, 34, 1),
                                    fontSize: 12),
                              ),
                      )
                    ],
                  )),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                color: Color.fromRGBO(255, 255, 255, 0),
              ),
              // width: MediaQuery.of(context).size.width * 0.5,
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    decoration: const BoxDecoration(boxShadow: [
                      BoxShadow(
                          color: Color.fromARGB(20, 0, 0, 0),
                          blurRadius: 10,
                          spreadRadius: 1),
                    ]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Colors.amber,
                        child: MaterialButton(
                          height: 60,
                          onPressed: () async {
                            if (valorFechahoraSalida == '' ||
                                asientosRutaController.text == '') {
                              showTopSnackBar(
                                context,
                                const CustomSnackBar.info(
                                  message:
                                      "Para continuar, debes completar los campos requeridos",
                                ),
                              );
                            } else {
                              final miRuta = await Lib().iniciarViaje(
                                  int.parse(widget.idRuta),
                                  int.parse(asientosRutaController.text),
                                  valorFechahoraSalida);
                              if (miRuta.length > 0) {
                                if (int.parse(miRuta[0]['cantidadActivos']) ==
                                    0) {
                                  showTopSnackBar(
                                    context,
                                    const CustomSnackBar.success(
                                      message: "Viaje creado correctamente",
                                    ),
                                  );
                                  const storage = FlutterSecureStorage();
                                  String? value =
                                      await storage.read(key: 'SESSION');
                                  Map<String, dynamic> usuarioResponse =
                                      json.decode(value ?? '');
                                  dynamic idChofer =
                                      usuarioResponse['iIdChofer'];
                                  Random random = Random();
                                  int randomNumber = random.nextInt(10000);
                                  int randomNumberB = random.nextInt(10000);

                                  FirebaseFirestore.instance
                                      .collection('movimientos')
                                      .doc(idChofer)
                                      .set({'random': randomNumber});
                                   
                                  FirebaseFirestore.instance
                                      .collection('busquedas')
                                      .doc('cambio')
                                      .set({'random': randomNumberB});
                                  
                                  // Navigator.of(context).pop();
                                  Navigator.of(context).pushAndRemoveUntil(
                                      CupertinoPageRoute<void>(
                                          builder: (BuildContext context) {
                                    return const Menu();
                                  }), (Route<dynamic> route) => false);

                                } else {
                                  showTopSnackBar(
                                    context,
                                    const CustomSnackBar.info(
                                      message:
                                          "No se pudo crear el viaje. Ya tienes un viaje en curso.",
                                    ),
                                  );
                                }
                              } else {
                                showTopSnackBar(
                                  context,
                                  const CustomSnackBar.error(
                                    message:
                                        "Lo sentimos, hubo un error, inténtalo nuevamente",
                                  ),
                                );
                              }
                            }
                          },
                          elevation: 0,
                          splashColor:  Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                height: 0,
                              ),
                              Text('Comenzar viaje',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(31, 31, 31, 1))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
