import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miruta/lista_de_pantalla.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MisRutas extends StatefulWidget {
  const MisRutas({Key? key}) : super(key: key);

  @override
  State<MisRutas> createState() => _MisRutasState();
}

class _MisRutasState extends State<MisRutas> {
  List misRutas = [];
  bool buscandoRutas = false;

  Future<void> listarRutas(idChofer) async {
    if (mounted) {
    setState(() {
      buscandoRutas = true;
    });

    }
    dynamic res = await Lib().listarRutas(idChofer);
  print('aquiiiiiiii aaaaa');
  print(res);
    if (mounted) {
      setState(() {
        misRutas = res;
        buscandoRutas = false;
      });
    }
  }
  
  Future<void> realTimeRutas() async {
    
     const storage = FlutterSecureStorage();
    String? value = await storage.read(key: 'SESSION');
    Map<String, dynamic> usuarioResponse = json.decode(value ?? '');
    dynamic idChofer = usuarioResponse['iIdChofer'];
   FirebaseFirestore.instance
        .collection("movimientos")
        .doc(idChofer)
        .snapshots()
        .listen((event) {
          print('aaaaa');
          listarRutas(idChofer);
        });
  }

  @override
  void initState() {
    realTimeRutas();
    super.initState();
  }

  void doNothing(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //     backgroundColor: const Color.fromARGB(0, 255, 255, 255),
      //     elevation: 0,
      //     title: const Text(''),
      //     centerTitle: true,
      //     leading: Builder(builder: (context) {
      //       return IconButton(
      //         icon: Container(
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(8),
      //             color: const Color.fromARGB(255, 255, 255, 255),
      //             boxShadow: const [
      //               BoxShadow(
      //                   color: Color.fromARGB(36, 0, 0, 0),
      //                   blurRadius: 5,
      //                   spreadRadius: 1),
      //             ],
      //           ),
      //           // color: Colors.white,
      //           height: 30,
      //           width: 30,
      //           child: const Icon(
      //             Icons.arrow_back_ios_rounded,
      //             color: Color.fromRGBO(21, 21, 21, 1),
      //             size: 14,
      //           ),
      //         ),
      //         onPressed: () {
      //           Navigator.of(context).pop();
      //         },
      //       );
      //     })
      //     ),
      body: Container(
        color: Colors.amber,
        child: Column(
          children: [
            Container(
              height: 210,
              width: MediaQuery.of(context).size.width,
              color: Colors.amber,
              child: Stack(
                children: [
                  Positioned(
                      top: 30,
                      left: 5,
                      child: IconButton(
                        icon: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color.fromARGB(255, 255, 255, 255),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromARGB(36, 0, 0, 0),
                                  blurRadius: 5,
                                  spreadRadius: 1),
                            ],
                          ),
                          // color: Colors.white,
                          height: 30,
                          width: 30,
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Color.fromRGBO(21, 21, 21, 1),
                            size: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )),
                  const Positioned(
                    top: 80,
                    left: 15,
                    child: Text(
                      'Mis viajes',
                      style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 21, 21, 21),
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  Positioned(
                    top: 110,
                    left: 15,
                    right: MediaQuery.of(context).size.width * 0.5,
                    child: const Text(
                      'Estas son todos tus viajes creados',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color.fromARGB(133, 21, 21, 21),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Positioned(
                    right: -35,
                    bottom: 10,
                    child: Image.asset(
                      'assets/images/png/default/carro.png',
                      scale: 1,
                      width: MediaQuery.of(context).size.width * 0.55,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 135,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute<void>(
                                builder: (BuildContext context) {
                              return const GestiosMisRutas();
                            }));
                          },
                          child: Container(
                            color: const Color.fromRGBO(21, 21, 21, 1),
                            width: 140,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Crear viaje',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15), topLeft: Radius.circular(15)),
              child: Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height - 210,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: buscandoRutas
                            ? const CupertinoActivityIndicator()
                            : misRutas.isEmpty
                                  ? Opacity(
                                      opacity: 0.15,
                                      child: Image.asset(
                                        'assets/images/png/default/vacio.png',
                                      ),
                                    )
                                  : ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(
                                          height: 1,
                                        ),
                                physics: const BouncingScrollPhysics(),
                                itemCount: misRutas.length,
                                itemBuilder: (context, index) {
                                  return Slidable(
                                    key: Key(misRutas[index]['Id']),

                                    closeOnScroll: false,
                                    // direction: DismissDirection.endToStart,
                                    endActionPane: ActionPane(
                                      dismissible: DismissiblePane(
                                        confirmDismiss: () async => await Lib().eliminarRuta(misRutas[index]['Id']),
                                        closeOnCancel: true,
                                          onDismissed: () async {
                                        // final mireselimina = await Lib()
                                        //     .eliminarRuta(
                                        //         misRutas[index]['Id']);
                                        // if (!mireselimina) {
                                        //   showTopSnackBar(
                                        //     context,
                                        //     const CustomSnackBar.error(
                                        //       message:
                                        //           "Fallo al eliminar el viaje. Inténtalo nuevamente.",
                                        //     ),
                                        //   );
                                        //   Navigator.of(context).pushReplacement(
                                        //       CupertinoPageRoute<void>(builder:
                                        //           (BuildContext context) {
                                        //     return const MisRutas();
                                        //   }));
                                        // } else {
                                          showTopSnackBar(
                                            context,
                                            const CustomSnackBar.success(
                                              message:
                                                  "Ruta eliminada correctamente",
                                            ),
                                          );
                                        // }
                                      }),
                                      extentRatio: 0.30,
                                      // A motion is a widget used to control how the pane animates.

                                      motion: const BehindMotion(),

                                      // All actions are defined in the children parameter.
                                      children: [
                                        // A SlidableAction can have an icon and/or a label.
                                        // SlidableAction(
                                        //   autoClose: true,
                                        //   onPressed: doNothing,
                                        //   backgroundColor: Colors.lightBlueAccent,
                                        //   foregroundColor: Colors.white,
                                        //   icon: Icons.mode_edit_rounded,
                                        //   // icon: Icons.mode_edit_rounded,
                                        //   label: 'Editar',
                                        // ),
                                        SlidableAction(
                                          // autoClose: true,
                                          onPressed: ((context) {
                                            AlertDialog(
                                              title: const Text(
                                                'Estás a punto de eliminar éste viaje',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: const <Widget>[
                                                    Text(
                                                      '¿Quieres eliminar el viaje?',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color.fromARGB(
                                                              128, 21, 21, 21)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextButton(
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        'No,gracias',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    28,
                                                                    28,
                                                                    28)),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color:
                                                          const Color.fromRGBO(
                                                              21, 21, 21, 1),
                                                    ),
                                                    child: TextButton(
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          'Si',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                          backgroundColor:
                                              const Color(0xFFFE4A49),
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Eliminar',
                                        ),
                                      ],
                                    ),
                                    direction: Axis.horizontal,
                                    useTextDirection: true,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.of(context).push(
                                                        CupertinoPageRoute<
                                                                void>(
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                      return  VerMapa(idRuta: misRutas[index]['Id'],origen:'MIS_RUTAS',
                                                      viajeEnCurso:false,
                                                      destino_lat: '',destino_long: '',salida_lat: '',salida_long: '',
                                                      nombreRutaController: '',
                                                      recogermosControlerNombre: '',
                                                      llegasControladorNombre: '',
                                                      direccionInicial: '',
                                                      direccionFinal: '',
                                                      distritoInicial: '',
                                                      distritoFinal: '',
                                                      provinciaInicial: '',
                                                      provinciaFinal: '',
                                                      regionInicial: '',
                                                      regionFinal: '',
                                                      direccionExactaInicial: '',
                                                      direccionExactaFinal: '',
                                                      );
                                                    }));
                                        },
                                        dense: true,
                                        // trailing: ClipRRect(
                                        //   borderRadius:
                                        //       BorderRadius.circular(4),
                                        //   child: Container(
                                        //     color: const Color.fromRGBO(
                                        //         21, 21, 21, 1),
                                        //     child: Padding(
                                        //       padding:
                                        //           const EdgeInsets.all(4.0),
                                        //       child: Text(
                                        //         misRutas[index]['iEstado'],
                                        //         style: const TextStyle(
                                        //             fontSize: 12,
                                        //             color: Color.fromARGB(
                                        //                 255, 255, 255, 255),
                                        //             fontWeight:
                                        //                 FontWeight.w500),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        title: Text(
                                          misRutas[index]['name'] ?? '-',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          '${misRutas[index]['vchRegionInicial'] ?? ''} - ${misRutas[index]['vchRegionFinal'] ?? ''}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color.fromARGB(
                                                  255, 199, 199, 199),
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
