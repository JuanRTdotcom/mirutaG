import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miruta/lista_de_pantalla.dart';
import 'package:url_launcher/url_launcher.dart';

class Asientos extends StatefulWidget {
  final String idRuta;
  final String origen;

  const Asientos({Key? key, required this.idRuta, required this.origen})
      : super(key: key);

  @override
  State<Asientos> createState() => _AsientosState();
}

class _AsientosState extends State<Asientos> {
  bool cargandoSolicitudes = false;
  List misSolicitudes = [];
  String misAvatars =
      'https://res.cloudinary.com/jrdotcom/image/upload/v1668389036/miRuta/s_rvhwte.png';

  Future<void> listarMisPasajeros() async {
    setState(() {
      cargandoSolicitudes = true;
    });
    dynamic res = await Lib().listarMisAsientos(widget.idRuta);
    print(res);
    if (mounted) {
      setState(() {
        misSolicitudes = res;
        cargandoSolicitudes = false;
      });
    }
  }

  Future<void> listarMisSolicitudesUsuarios() async {
    setState(() {
      cargandoSolicitudes = true;
    });

    dynamic res = await Lib().listarSolicitudesxidRutaUsuario(widget.idRuta);
    if (mounted) {
      setState(() {
        misSolicitudes = res;
        cargandoSolicitudes = false;
      });
    }
  }

  verCambiosSolicitudes() async {
    FirebaseFirestore.instance
        .collection("busquedas")
        .doc('cambio')
        .snapshots()
        .listen((event) async {
      if (widget.origen == "CONDUCTOR") {
        dynamic res = await Lib().listarSolicitudesxidRuta(widget.idRuta);
        if (mounted) {
          setState(() {
            misSolicitudes = res;
          });
        }
      } else {
        dynamic res =
            await Lib().listarSolicitudesxidRutaUsuario(widget.idRuta);
        if (mounted) {
          setState(() {
            misSolicitudes = res;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.origen == 'CONDUCTOR') {
      listarMisPasajeros();
    } else {
      // listarMisSolicitudesUsuarios();
    }
    // verCambiosSolicitudes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
          title: const Text(
            'Mis pasajeros',
            style: TextStyle(fontSize: 12),
          ),
          centerTitle: true,
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
              ),
              onPressed: () => Navigator.of(context).pop(),
            );
          })),
      body: cargandoSolicitudes
          ? const Center(child: CupertinoActivityIndicator())
          : misSolicitudes.isEmpty
              ? Center(
                  child: Opacity(
                    opacity: .3,
                    child: Column(
                      children: const [
                        SizedBox(
                          height: 40,
                        ),
                        Icon(
                          Icons.person_off_outlined,
                          size: 40,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'No tienes pasajeros actualmente',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: misSolicitudes.length,
                  itemBuilder: (context, index) {
                    Random r = Random();
                    int resultado = r.nextInt((8 - 0) + 1) + 0;
                    return Padding(
                      padding: const EdgeInsets.only(
                          right: 20, left: 20, top: 0, bottom: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 246, 244, 226)
                                  .withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ListTile(
                          minVerticalPadding: 12,
                          onTap: () {
                            // Navigator.of(context).push(CupertinoPageRoute<void>(
                            //     builder: (BuildContext context) {
                            //   return NegociacionAsiento(
                            //     idRuta: misSolicitudes[index]['idRutaSv'],
                            //     origen: widget.origen=='PASAJERO'?'PASAJERO':'CONDUCTOR',
                            //     idSolicitudServicio: misSolicitudes[index]['Id'],
                            //     salida_lat: misSolicitudes[index]['vchLatInicial'],
                            //     salida_long: misSolicitudes[index]['vchLongInicial'],
                            //     destino_lat: misSolicitudes[index]['vchLatFinal'],
                            //     destino_long: misSolicitudes[index]['vchLongFinal'],
                            //     monto: misSolicitudes[index]['costoPropuesto'],
                            //     nombreUsuario: '${misSolicitudes[index]['vchNombres']} ${misSolicitudes[index]['vchApellidoP']}',
                            //   );
                            // }));
                          },
                          title: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      misSolicitudes[index]['vchUrlImage'] ??
                                          misAvatars),
                                  backgroundColor:
                                      const Color.fromARGB(255, 209, 215, 219),
                                ),
                              ),
                              Container(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${misSolicitudes[index]['vchNombres']} ${misSolicitudes[index]['vchApellidoP']} ${misSolicitudes[index]['vchApellidoM']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      height: 5,
                                    ),
                                    const Text(
                                      '+400 viajes',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color.fromARGB(
                                              255, 190, 190, 190)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            children: [
                              Container(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        var tel =
                                            misSolicitudes[index]['vchCelular'];
                                        if (await canLaunchUrl(Uri(
                                          scheme: 'tel',
                                          path: tel,
                                        ))) {
                                          await launchUrl(Uri(
                                            scheme: 'tel',
                                            path: tel,
                                          ));
                                        }
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.phone_in_talk_rounded,
                                                  size: 18,
                                                  color: Color.fromARGB(
                                                      255, 43, 128, 47),
                                                ),
                                                Container(
                                                  width: 5,
                                                ),
                                                const Text(
                                                  'Llamar',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          )),
                                    ),
                                  ),
                                  Container(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        var tel =
                                            misSolicitudes[index]['vchCelular'];
                                        var uri =
                                            'whatsapp://send?phone=+51$tel&text=Hola';
                                        if (await canLaunch(uri)) {
                                          await launch(uri);
                                        }
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.whatsapp,
                                                  size: 18,
                                                  color: Color.fromARGB(
                                                      255, 43, 128, 47),
                                                ),
                                                Container(
                                                  width: 5,
                                                ),
                                                const Text(
                                                  'Mensaje',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                              Container(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                        child: Text(
                                            misSolicitudes[index]
                                                ['vDireccionExactaInicio'],
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Color.fromARGB(
                                                    255, 54, 54, 54)))),
                                  )
                                ],
                              ),
                              Container(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: Text(
                                          misSolicitudes[index]
                                              ['vDireccionExactaFin'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Color.fromARGB(
                                                  255, 54, 54, 54))))
                                ],
                              ),
                              Container(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Material(
                                      color: 
                                      misSolicitudes[index]['iEstado']=='11'
                                      ? Colors.greenAccent
                                      : Colors.black,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          dynamic miRes = true;
                                          if(misSolicitudes[index]['iEstado']=='11'){
                                          miRes = await  recogerViaje(context, index) ?? false;

                                          }else{
                                          miRes = await  finalizarViaje(context, index) ?? false;

                                          }
                                          if (miRes) {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        height: 35,
                                        elevation: 0,
                                        splashColor: Colors.transparent,
                                        child:  Text(
                                          misSolicitudes[index]['iEstado']=='11'
                                          ? 'Recoger pasajero'
                                          :  'Finalizar viaje',
                                            style:  TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: 
                                                misSolicitudes[index]['iEstado']=='11'
                                                ? Colors.black
                                                : Colors.white)),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          // subtitle: Text(
                          //   "Ha ofertado S/ ${num.parse(misSolicitudes[index]['costoPropuesto']).toStringAsFixed(2)} por un asiento en el viaje ${misSolicitudes[index]['name']}",
                          //   maxLines: 2,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: const TextStyle(
                          //     fontSize: 10,
                          //   ),
                          // ),
                          // leading: CircleAvatar(
                          //   backgroundImage: NetworkImage(misSolicitudes[index]
                          //           ['vchUrlImg'] ??
                          //       misAvatars[6]),
                          //   backgroundColor:
                          //       const Color.fromARGB(255, 209, 215, 219),
                          // ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  finalizarViaje(BuildContext context, int index) async {
    showDialog<bool>(
        context: context, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Fin de viaje',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    '¿Deseas finalizar el viaje de ${misSolicitudes[index]['vchNombres']} ${misSolicitudes[index]['vchApellidoP']} ${misSolicitudes[index]['vchApellidoM']}? al finalizar su viaje, podrán calificar el viaje y disminuirá el espacio del asiento',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(128, 21, 21, 21)),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No',
                      style: TextStyle(
                          fontSize: 14, color: Color.fromARGB(255, 28, 28, 28)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromRGBO(21, 21, 21, 1),
                  ),
                  child: TextButton(
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Sí, finalizar',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                    onPressed: () async {
                      // setState(() {
                      //   aceptandoSolicitud =
                      //       true;
                      // });

                      final verificaSaldo = await Lib()
                          .finalizarAsientoPasajero(
                              misSolicitudes[index]['idServicio']);

                      Random random = Random();
                      int randomNumber = random.nextInt(10000);
                      int randomNumberb = random.nextInt(10000);
                      FirebaseFirestore.instance
                          .collection('solicitudes')
                          .doc(widget.idRuta)
                          .set({'random': randomNumber});
                      FirebaseFirestore.instance
                          .collection('busquedas')
                          .doc('cambio')
                          .set({'random': randomNumberb});

                      showTopSnackBar(
                        context,
                        const CustomSnackBar.success(
                          message: "Viaje de pasajero culminado correctamente",
                        ),
                      );
                      Navigator.pop(context, true);
                    },
                  ),
                ),
              ),
            ],
          );
        });
  }
  recogerViaje(BuildContext context, int index) async {
    showDialog<bool>(
        context: context, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Recoger pasajero',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    '¿Deseas recoger a ${misSolicitudes[index]['vchNombres']} ${misSolicitudes[index]['vchApellidoP']} ${misSolicitudes[index]['vchApellidoM']}? Asegúrate de que el pasajero suba al auto.',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(128, 21, 21, 21)),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No',
                      style: TextStyle(
                          fontSize: 14, color: Color.fromARGB(255, 28, 28, 28)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromRGBO(21, 21, 21, 1),
                  ),
                  child: TextButton(
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Sí, recoger',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                    onPressed: () async {
                      // setState(() {
                      //   aceptandoSolicitud =
                      //       true;
                      // });

                      final verificaSaldo = await Lib()
                          .recogerAsientoPasajero(
                              misSolicitudes[index]['idServicio']);

                      Random random = Random();
                      int randomNumber = random.nextInt(10000);
                      int randomNumberb = random.nextInt(10000);
                      FirebaseFirestore.instance
                          .collection('solicitudes')
                          .doc(widget.idRuta)
                          .set({'random': randomNumber});
                      FirebaseFirestore.instance
                          .collection('busquedas')
                          .doc('cambio')
                          .set({'random': randomNumberb});

                      showTopSnackBar(
                        context,
                        const CustomSnackBar.success(
                          message: "El pasajero fue recogido correctamente",
                        ),
                      );
                      Navigator.pop(context, true);
                    },
                  ),
                ),
              ),
            ],
          );
        });
  }
}
  