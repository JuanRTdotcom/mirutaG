import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miruta/lista_de_pantalla.dart';

class Mapa extends StatefulWidget {
  const Mapa({Key? key}) : super(key: key);

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  late GoogleMapController _googleMapController;

  String miLugar = '';

  bool buscandoUbicacionNombre = false,
      moviendoPin = false,
      cargaControladorMapa = false,
      modoConductor = false;

  TextEditingController inicioControlador = TextEditingController();
  TextEditingController recogermosControler = TextEditingController();
  String recogermosControlerNombre = '';
  String recogermosControlerUbicacion = '';
  TextEditingController llegasControlador = TextEditingController();
  String llegasControladorNombre = '';
  String llegasControladorUbicacion = '';
  FocusNode recogermosControlerFocus = FocusNode();
  FocusNode llegasControladorFocus = FocusNode();
  String salida_lat = '';
  String salida_long = '';
  String destino_lat = '';
  String destino_long = '';
  String direccionInicial = '';
  String direccionFinal = '';

  String distritoInicial = '';
  String distritoFinal = '';

  String provinciaInicial = '';
  String provinciaFinal = '';

  String regionInicial = '';
  String regionFinal = '';

  String direccionExactaInicial = '';
  String direccionExactaFinal = '';

  double posicionBuscador = 0;

  double posicionBuscador_esconde = -80;
  double posicionBuscador_revela = 0;

  double _inicioBotonMiUbicacion = 140;
  final double _inicioBotonMiUbicacion_esconde = -140;
  final double _inicioBotonMiUbicacion_revela = 140;
  dynamic _position;
  bool seestamoviendo = false, cargandoRuta = false, tieneViajeenCurso = false;

  String nombreViajeenCurso = '';
  String idRutaCurso = '';
  String inicio = '';
  String fin = '';
  String estadoViaje = '';
  String distritoinicio = '';
  String distritofin = '';

  StreamController<double> streamLogintud = StreamController();
  StreamController<double> streamLatitud = StreamController();

  List misRutas = [];
  dynamic misRecomendacionesBusqueda = [];
  double longS = -75.46123925596476;
  double latS = -10.902044575597206;
  dynamic misDireccionesStremCorriendo;
  int progresoRuta = 0;

  late String imagenPerfil =
      'https://res.cloudinary.com/jrdotcom/image/upload/v1668389036/miRuta/s_rvhwte.png';
  // late String imagenPerfil = 'assets/images/png/default/usuario.png';
  @override
  void initState() {
    obtenerDataSesion();

    super.initState();
    streamLogintud.stream.listen((event) {
      longS = event;
    });
    streamLatitud.stream.listen((event) {
      latS = event;
    });
  }

  void verSihayViajeActivo(idChofer) async {
    dynamic res = await Lib().validarViajeActivo(idChofer);
    if (res.length > 0) {
      var i = res[0];
      if (mounted) {
        setState(() {
          idRutaCurso = i['Id'];
          nombreViajeenCurso = i['name'];
          estadoViaje = 'En progreso';
          inicio = i['vchRegionInicial'];
          distritoinicio = i['vchDistritoInicial'];
          distritofin = i['vchDistritoFinal'];
          fin = i['vchRegionFinal'];
          tieneViajeenCurso = true;
          switch (i['estadoServicio'].trim()) {
            case 'CREADO':
              setState(() {
                progresoRuta = 1;
              });
              break;
            case 'EN_PARADERO':
              setState(() {
                progresoRuta = 2;
              });
              break;
            case 'EN_RUTA':
              setState(() {
                progresoRuta = 3;
              });
              break;
            case 'FINALIZADO':
              setState(() {
                progresoRuta = 4;
              });
              break;
            case 'NO_DISPONIBLE':
              setState(() {
                progresoRuta = 5;
              });
              break;
            default:
              break;
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          tieneViajeenCurso = false;
        });
      }
    }
  }

  void listarRutas(idChofer) async {
    dynamic res = await Lib().listarRutas(idChofer);
    if (res.length > 0) {
      if (mounted) {
        setState(() {
          misRutas = res;
        });
      }
    }
  }

  void listarRutasUsuario(idUsuario) async {
    // dynamic res = await Lib().verEstadoUsuario(idUsuario);
    dynamic res = await Lib().validarViajeActivoUsuario(idUsuario);
    // res = res.reversed.toList();
    print(res);
    if (res.length > 0) {
      // for (final i in res) {
      if (res[0]['estadoServicio'].trim() == 'EN_PARADERO' ||
          res[0]['estadoServicio'].trim() == 'EN_RUTA') {
        if (mounted) {
          setState(() {
            idRutaCurso = res[0]['Id'];
            nombreViajeenCurso = res[0]['name'];
            estadoViaje = 'En progreso';
            inicio = res[0]['vchRegionInicial'];
            distritoinicio = res[0]['vchDistritoInicial'];
            distritofin = res[0]['vchDistritoFinal'];
            fin = res[0]['vchRegionFinal'];
            tieneViajeenCurso = true;
            switch (res[0]['estadoServicio'].trim()) {
              case 'CREADO':
                setState(() {
                  progresoRuta = 1;
                });
                break;
              case 'EN_PARADERO':
                setState(() {
                  progresoRuta = 2;
                });
                break;
              case 'EN_RUTA':
                setState(() {
                  progresoRuta = 3;
                });
                break;
              case 'FINALIZADO':
                setState(() {
                  progresoRuta = 4;
                });
                break;
              case 'NO_DISPONIBLE':
                setState(() {
                  progresoRuta = 5;
                });
                break;
              default:
                break;
            }
          });
        }
      } else {
        // // dynamic res = await Lib().verEstadoUsuarioSiTermino(idUsuario);
        // if (res[0]['estadoServicio'].trim() == 'FINALIZADO' &&
        //     int.parse(res[0]['calificaciones']) < 1) {
        // Navigator.of(context).pushAndRemoveUntil(
        //     CupertinoPageRoute<void>(builder: (BuildContext context) {
        //   return Rating_pasajero(
        //       idRuta: res[0]['Id'], idUsuario: idUsuario ?? '1');
        // }), (Route<dynamic> route) => false);
        // }
        if (mounted) {
          setState(() {
            progresoRuta = 1;
            tieneViajeenCurso = false;
          });
        }
      }
      // }
    } else {
      dynamic resb = await Lib().validarSiTieneParaRanking(idUsuario);
      if (resb.length > 0) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute<void>(builder: (BuildContext context) {
            return Rating_pasajero(
                idServicio: resb[0]['iIdServicio'],
                idSoliServicio: resb[0]['Id'],
                idUsuario: idUsuario ?? '1');
          }), (Route<dynamic> route) => false);
        }
      } else {
        if (mounted) {
          setState(() {
            progresoRuta = 1;
            tieneViajeenCurso = false;
          });
        }
      }
    }
    // if (mounted) {
    //   setState(() {
    //     misRutas = res;
    //   });
    // }
  }

  void obtenerDataSesion() async {
    const storage = FlutterSecureStorage();
    String? value = await storage.read(key: 'SESSION');
    String? valueModo = await storage.read(key: 'Modo');
    Map<String, dynamic> usuarioResponse = json.decode(value ?? '');
    dynamic idChofer = usuarioResponse['iIdChofer'];
    dynamic idUsuario = usuarioResponse['id'];

    if (valueModo == '0') {
      //conductor
      listarRutas(idChofer);
      FirebaseFirestore.instance
          .collection("movimientos")
          .doc(idChofer)
          .snapshots()
          .listen((event) {
        print('aaaaa');
        listarRutas(idChofer);
        verSihayViajeActivo(idChofer);
      });
      setState(() {
        modoConductor = true;
        imagenPerfil = usuarioResponse['imageUrl'];
      });
    } else {
      // debe cambiar el id de usuario, porque no tengo el id del chofer
      listarRutasUsuario(idUsuario);
      FirebaseFirestore.instance
          .collection("busquedas")
          .doc('cambio')
          .snapshots()
          .listen((event) {
        print('aaaaa');
        listarRutasUsuario(idUsuario);
      });

      setState(() {
        modoConductor = false;
        imagenPerfil = usuarioResponse['imageUrl'];
      });
    }
  }

  void buscadorLugares(value, streamBuscarLugar) async {
    if (recogermosControlerFocus.hasFocus) {
      if (value.length > 2) {
        dynamic misLugares =
            await Lib().obtenerLugares(recogermosControler.text);
        streamBuscarLugar.add(misLugares);
      } else {
        dynamic misLugares = await Lib().obtenerLugares('');
        streamBuscarLugar.add(misLugares);
      }
    } else if (llegasControladorFocus.hasFocus) {
      if (value.length > 2) {
        dynamic misLugares = await Lib().obtenerLugares(llegasControlador.text);
        streamBuscarLugar.add(misLugares);
      } else {
        dynamic misLugares = await Lib().obtenerLugares('');
        streamBuscarLugar.add(misLugares);
      }
    }
  }

  void misRutasCreadas() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: const Color.fromARGB(174, 21, 21, 21),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.94,
              minChildSize: 0.94,
              maxChildSize: 1,
              builder: (_, controller) {
                return ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Container(
                        color: Colors.white,
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                    width: 30,
                                    height: 3,
                                    color: const Color.fromRGBO(21, 21, 21, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: const [
                                Text('Mis Viajes creados',
                                    style: TextStyle(
                                        color: Color.fromRGBO(21, 21, 21, 1),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: misRutas.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 6),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          boxShadow: [
                                            BoxShadow(
                                                color:
                                                    Color.fromARGB(17, 0, 0, 0),
                                                blurRadius: 3,
                                                spreadRadius: 1),
                                          ]),
                                      child: ListTile(
                                        onTap: () async {
                                          Random random = Random();
                                          int randomNumber =
                                              random.nextInt(10000);
                                          await FirebaseFirestore.instance
                                              .collection('busquedas')
                                              .doc('cambio')
                                              .set({'random': randomNumber});
                                          Navigator.of(context).push(
                                              CupertinoPageRoute<void>(builder:
                                                  (BuildContext context) {
                                            return VerMapa(
                                              idRuta: misRutas[index]['Id'],
                                              origen: 'CONDUCTOR',
                                              viajeEnCurso: tieneViajeenCurso,
                                              salida_lat: '',
                                              salida_long: '',
                                              destino_lat: '',
                                              destino_long: '',
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
                                        title: Row(
                                          children: [
                                            Text(
                                              misRutas[index]['name'],
                                              style: const TextStyle(
                                                  color: Color.fromRGBO(
                                                      21, 21, 21, 1),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            // ClipRRect(
                                            //   borderRadius:
                                            //       BorderRadius.circular(4),
                                            //   child: Container(
                                            //     color: const Color.fromRGBO(
                                            //         21, 21, 21, 1),
                                            //     child: Padding(
                                            //       padding:
                                            //           const EdgeInsets.all(4.0),
                                            //       child: Text(
                                            //           'S/ ${double.parse(misRutas[index]['mPrecio']).toStringAsFixed(2)}',
                                            //           style: const TextStyle(
                                            //               color: Colors.white,
                                            //               fontSize: 10)),
                                            //     ),
                                            //   ),
                                            // )
                                          ],
                                        ),
                                        subtitle: Text(
                                          '${misRutas[index]['vchRegionInicial']} - ${misRutas[index]['vchRegionFinal']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 10),
                                        ),
                                        trailing: misRutas[index]['iEstado'] ==
                                                '3'
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Container(
                                                  color: const Color.fromARGB(
                                                      255, 45, 212, 51),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Text(
                                                      'En proceso',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                child: const Icon(
                                                  Icons
                                                      .arrow_circle_right_outlined,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                }),
                          )
                        ])));
              });
        });
  }

  Future<void> obtenerLatitudLongitud() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latS, longS);
    Placemark lugar = placemarks[0];
    Placemark lugar2 = placemarks[1];
    Placemark lugar3 = placemarks[2];
    Placemark lugar4 = placemarks[3];
    Placemark lugar5 = placemarks[4];

    if (lugar.thoroughfare != '' && lugar.street!.length > 4) {
      if (mounted) {
        setState(() {
          miLugar = lugar.street ?? 'Desconocido';
          posicionBuscador = posicionBuscador_revela;
          _inicioBotonMiUbicacion = _inicioBotonMiUbicacion_revela;
          buscandoUbicacionNombre = false;
        });
      }
    } else {
      if (lugar.subLocality != '') {
        if (mounted) {
          setState(() {
            miLugar = '${lugar.subLocality}, ${lugar.locality}';
            posicionBuscador = posicionBuscador_revela;
            _inicioBotonMiUbicacion = _inicioBotonMiUbicacion_revela;
            buscandoUbicacionNombre = false;
          });
        }
      } else {
        if (lugar2.thoroughfare != '' && lugar2.street!.length > 4) {
          if (mounted) {
            setState(() {
              miLugar = lugar2.street ?? 'Desconocido';
              posicionBuscador = posicionBuscador_revela;
              _inicioBotonMiUbicacion = _inicioBotonMiUbicacion_revela;
              buscandoUbicacionNombre = false;
            });
          }
        } else {
          if (lugar2.subLocality != '') {
            if (mounted) {
              setState(() {
                miLugar = '${lugar2.subLocality}, ${lugar2.locality}';
                posicionBuscador = posicionBuscador_revela;
                _inicioBotonMiUbicacion = _inicioBotonMiUbicacion_revela;
                buscandoUbicacionNombre = false;
              });
            }
          } else {
            if (lugar3.thoroughfare != '' && lugar3.street!.length > 4) {
              if (mounted) {
                setState(() {
                  miLugar = lugar3.street ?? 'Desconocido';
                  posicionBuscador = posicionBuscador_revela;
                  _inicioBotonMiUbicacion = _inicioBotonMiUbicacion_revela;
                  buscandoUbicacionNombre = false;
                });
              }
            } else {
              if (lugar3.subLocality != '') {
                if (mounted) {
                  setState(() {
                    miLugar = '${lugar3.subLocality}, ${lugar3.locality}';
                    posicionBuscador = posicionBuscador_revela;
                    _inicioBotonMiUbicacion = _inicioBotonMiUbicacion_revela;
                    buscandoUbicacionNombre = false;
                  });
                }
              } else {
                if (lugar4.thoroughfare != '' && lugar4.street!.length > 4) {
                  if (mounted) {
                    setState(() {
                      miLugar = lugar4.street ?? 'Desconocido';
                      posicionBuscador = posicionBuscador_revela;
                      _inicioBotonMiUbicacion = _inicioBotonMiUbicacion_revela;
                      buscandoUbicacionNombre = false;
                    });
                  }
                } else {
                  if (lugar4.subLocality != '') {
                    if (mounted) {
                      setState(() {
                        miLugar = '${lugar4.subLocality}, ${lugar4.locality}';
                        posicionBuscador = posicionBuscador_revela;
                        _inicioBotonMiUbicacion =
                            _inicioBotonMiUbicacion_revela;
                        buscandoUbicacionNombre = false;
                      });
                    }
                  } else {
                    if (lugar5.thoroughfare != '' &&
                        lugar5.street!.length > 4) {
                      if (mounted) {
                        setState(() {
                          miLugar = lugar5.street ?? 'Desconocido';
                          posicionBuscador = posicionBuscador_revela;
                          _inicioBotonMiUbicacion =
                              _inicioBotonMiUbicacion_revela;
                          buscandoUbicacionNombre = false;
                        });
                      }
                    } else {
                      if (mounted) {
                        setState(() {
                          miLugar = '${lugar5.subLocality}, ${lugar5.locality}';
                          posicionBuscador = posicionBuscador_revela;
                          _inicioBotonMiUbicacion =
                              _inicioBotonMiUbicacion_revela;
                          buscandoUbicacionNombre = false;
                        });
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  void ocultarElementosdeVentada() {
    setState(() {
      posicionBuscador = posicionBuscador_esconde;
      _inicioBotonMiUbicacion = _inicioBotonMiUbicacion_esconde;
    });
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
    streamLogintud.close();
    streamLatitud.close();
  }

  @override
  Widget build(BuildContext context) {
    const _camarainicial = CameraPosition(
        target: LatLng(-10.902044575597206, -75.46123925596476), zoom: 6.5);
    return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(children: [
              GoogleMap(
                  initialCameraPosition: _camarainicial,
                  onMapCreated: (controller) {
                    _googleMapController = controller;
                    setState(() {
                      cargaControladorMapa = true;
                    });
                    Lib().obtenerUbicacionInicial(_googleMapController);
                  },
                  compassEnabled: false,
                  myLocationButtonEnabled: false,
                  rotateGesturesEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  onTap: (position) {},
                  onCameraMove: (CameraPosition position) {
                    streamLatitud.add(position.target.latitude);
                    streamLogintud.add(position.target.longitude);
                  },
                  onCameraIdle: () {
                    setState(() {
                      moviendoPin = false;
                      buscandoUbicacionNombre = true;
                    });

                    obtenerLatitudLongitud();
                  },
                  onCameraMoveStarted: () {
                    setState(() {
                      moviendoPin = true;
                    });
                    ocultarElementosdeVentada();
                  }),
              Mapa_usuario_medio_pantalla(imagenPerfil: imagenPerfil),
              Mapa_popup_nombre_calles(
                  moviendoPin: moviendoPin,
                  buscandoUbicacionNombre: buscandoUbicacionNombre,
                  miLugar: miLugar),
              cargaControladorMapa
                  ? Mapa_boton_ubicacion_actual(
                      inicioBotonMiUbicacion: _inicioBotonMiUbicacion,
                      mapaControlador: _googleMapController)
                  : const SizedBox(
                      width: 0,
                    ),
              modoConductor
                  ? tieneViajeenCurso
                      ? Mapa_fondo_iniciar_viaje(
                          posicionBuscador: posicionBuscador,
                          nombre: 'Viaje en curso',
                        )
                      : Mapa_fondo_iniciar_viaje(
                          posicionBuscador: posicionBuscador,
                          nombre: 'Elige un viaje')
                  : tieneViajeenCurso
                      ? Mapa_fondo_a_donde_vamos(
                          posicionBuscador: posicionBuscador,
                          nombre: 'Viaje en curso')
                      : Mapa_fondo_a_donde_vamos(
                          posicionBuscador: posicionBuscador,
                          nombre: 'Busquemos un viaje para ti'),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.fastOutSlowIn,
                left: 20,
                right: 20,
                bottom: posicionBuscador,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                    color: Color.fromRGBO(255, 255, 255, 0),
                  ),
                  // width: MediaQuery.of(context).size.width * 0.5,
                  height: 90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: modoConductor
                                    ? tieneViajeenCurso
                                        ? MaterialButton(
                                            height: 70,
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  CupertinoPageRoute<void>(
                                                      builder: (BuildContext
                                                          context) {
                                                return VerMapa(
                                                  idRuta: idRutaCurso,
                                                  origen: 'CONDUCTOR',
                                                  viajeEnCurso:
                                                      tieneViajeenCurso,
                                                  salida_lat: '',
                                                  salida_long: '',
                                                  destino_lat: '',
                                                  destino_long: '',
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
                                            elevation: 0,
                                            splashColor: Colors.transparent,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            width: 14,
                                                            height: 14,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14),
                                                                border: Border.all(
                                                                    width: 2,
                                                                    color: progresoRuta >=
                                                                            1
                                                                        ? Colors
                                                                            .amber
                                                                        : const Color.fromARGB(
                                                                            255,
                                                                            214,
                                                                            214,
                                                                            214)),
                                                                color: progresoRuta >
                                                                        1
                                                                    ? Colors
                                                                        .amber
                                                                    : Colors
                                                                        .white),
                                                            child: progresoRuta >
                                                                    1
                                                                ? const Icon(
                                                                    Icons.check,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255),
                                                                    size: 10,
                                                                  )
                                                                : const Text(
                                                                    ''),
                                                          ),
                                                          Container(
                                                            height: 2,
                                                            width: 8,
                                                            color: progresoRuta >
                                                                    1
                                                                ? Colors.amber
                                                                : const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    214,
                                                                    214,
                                                                    214),
                                                          ),
                                                          Container(
                                                            width: 14,
                                                            height: 14,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14),
                                                                border: Border.all(
                                                                    width: 2,
                                                                    color: progresoRuta >=
                                                                            2
                                                                        ? Colors
                                                                            .amber
                                                                        : const Color.fromARGB(
                                                                            255,
                                                                            214,
                                                                            214,
                                                                            214)),
                                                                color: progresoRuta >
                                                                        2
                                                                    ? Colors
                                                                        .amber
                                                                    : Colors
                                                                        .white),
                                                            child: progresoRuta >
                                                                    2
                                                                ? const Icon(
                                                                    Icons.check,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255),
                                                                    size: 10,
                                                                  )
                                                                : const Text(
                                                                    ''),
                                                          ),
                                                          Container(
                                                            height: 2,
                                                            width: 8,
                                                            color: progresoRuta >
                                                                    2
                                                                ? Colors.amber
                                                                : const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    214,
                                                                    214,
                                                                    214),
                                                          ),
                                                          Container(
                                                            width: 14,
                                                            height: 14,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14),
                                                                border: Border.all(
                                                                    width: 2,
                                                                    color: progresoRuta >=
                                                                            3
                                                                        ? Colors
                                                                            .amber
                                                                        : const Color.fromARGB(
                                                                            255,
                                                                            214,
                                                                            214,
                                                                            214)),
                                                                color: progresoRuta >
                                                                        3
                                                                    ? Colors
                                                                        .amber
                                                                    : Colors
                                                                        .white),
                                                            child: progresoRuta >
                                                                    3
                                                                ? const Icon(
                                                                    Icons.check,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255),
                                                                    size: 10,
                                                                  )
                                                                : const Text(
                                                                    ''),
                                                          ),
                                                          // Container(
                                                          //   height: 2,
                                                          //   width: 8,
                                                          //   color: progresoRuta >
                                                          //           3
                                                          //       ? Colors.amber
                                                          //       : const Color
                                                          //               .fromARGB(
                                                          //           255,
                                                          //           214,
                                                          //           214,
                                                          //           214),
                                                          // ),
                                                          // Container(
                                                          //   width: 14,
                                                          //   height: 14,
                                                          //   decoration: BoxDecoration(
                                                          //       borderRadius:
                                                          //           BorderRadius
                                                          //               .circular(
                                                          //                   14),
                                                          //       border: Border.all(
                                                          //           width: 2,
                                                          //           color: progresoRuta >=
                                                          //                   4
                                                          //               ? Colors
                                                          //                   .amber
                                                          //               : const Color.fromARGB(
                                                          //                   255,
                                                          //                   214,
                                                          //                   214,
                                                          //                   214)),
                                                          //       color: progresoRuta >
                                                          //               4
                                                          //           ? Colors
                                                          //               .amber
                                                          //           : Colors
                                                          //               .white),
                                                          //   child: progresoRuta >
                                                          //           4
                                                          //       ? const Icon(
                                                          //           Icons.check,
                                                          //           color: Color
                                                          //               .fromARGB(
                                                          //                   255,
                                                          //                   255,
                                                          //                   255,
                                                          //                   255),
                                                          //           size: 10,
                                                          //         )
                                                          //       : const Text(
                                                          //           ''),
                                                          // ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(nombreViajeenCurso,
                                                          style: const TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      21,
                                                                      21,
                                                                      21,
                                                                      1),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(
                                                        '$distritoinicio, $inicio - $distritofin, $fin',
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    141,
                                                                    141,
                                                                    141),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons
                                                      .keyboard_arrow_right_rounded,
                                                )
                                              ],
                                            ),
                                          )
                                        : MaterialButton(
                                            height: 70,
                                            onPressed: () async =>
                                                misRutasCreadas(),
                                            elevation: 0,
                                            splashColor: Colors.transparent,
                                            child: Row(
                                              children: const [
                                                Icon(
                                                  Icons.rocket_launch_rounded,
                                                  color: Color.fromARGB(
                                                      255, 131, 131, 131),
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text('Iniciar un viaje',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color.fromARGB(
                                                            255,
                                                            131,
                                                            131,
                                                            131))),
                                              ],
                                            ),
                                          )
                                    : tieneViajeenCurso
                                        ? MaterialButton(
                                            height: 70,
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  CupertinoPageRoute<void>(
                                                      builder: (BuildContext
                                                          context) {
                                                return VerMapa(
                                                  idRuta: idRutaCurso,
                                                  origen: 'PASAJERO',
                                                  viajeEnCurso:
                                                      tieneViajeenCurso,
                                                  salida_lat: '',
                                                  salida_long: '',
                                                  destino_lat: '',
                                                  destino_long: '',
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
                                            elevation: 0,
                                            splashColor: Colors.transparent,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            width: 14,
                                                            height: 14,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14),
                                                                border: Border.all(
                                                                    width: 2,
                                                                    color: progresoRuta >=
                                                                            1
                                                                        ? Colors
                                                                            .amber
                                                                        : const Color.fromARGB(
                                                                            255,
                                                                            214,
                                                                            214,
                                                                            214)),
                                                                color: progresoRuta >
                                                                        1
                                                                    ? Colors
                                                                        .amber
                                                                    : Colors
                                                                        .white),
                                                            child: progresoRuta >
                                                                    1
                                                                ? const Icon(
                                                                    Icons.check,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255),
                                                                    size: 10,
                                                                  )
                                                                : const Text(
                                                                    ''),
                                                          ),
                                                          Container(
                                                            height: 2,
                                                            width: 8,
                                                            color: progresoRuta >
                                                                    1
                                                                ? Colors.amber
                                                                : const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    214,
                                                                    214,
                                                                    214),
                                                          ),
                                                          Container(
                                                            width: 14,
                                                            height: 14,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14),
                                                                border: Border.all(
                                                                    width: 2,
                                                                    color: progresoRuta >=
                                                                            2
                                                                        ? Colors
                                                                            .amber
                                                                        : const Color.fromARGB(
                                                                            255,
                                                                            214,
                                                                            214,
                                                                            214)),
                                                                color: progresoRuta >
                                                                        2
                                                                    ? Colors
                                                                        .amber
                                                                    : Colors
                                                                        .white),
                                                            child: progresoRuta >
                                                                    2
                                                                ? const Icon(
                                                                    Icons.check,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255),
                                                                    size: 10,
                                                                  )
                                                                : const Text(
                                                                    ''),
                                                          ),
                                                          Container(
                                                            height: 2,
                                                            width: 8,
                                                            color: progresoRuta >
                                                                    2
                                                                ? Colors.amber
                                                                : const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    214,
                                                                    214,
                                                                    214),
                                                          ),
                                                          Container(
                                                            width: 14,
                                                            height: 14,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14),
                                                                border: Border.all(
                                                                    width: 2,
                                                                    color: progresoRuta >=
                                                                            3
                                                                        ? Colors
                                                                            .amber
                                                                        : const Color.fromARGB(
                                                                            255,
                                                                            214,
                                                                            214,
                                                                            214)),
                                                                color: progresoRuta >
                                                                        3
                                                                    ? Colors
                                                                        .amber
                                                                    : Colors
                                                                        .white),
                                                            child: progresoRuta >
                                                                    3
                                                                ? const Icon(
                                                                    Icons.check,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255),
                                                                    size: 10,
                                                                  )
                                                                : const Text(
                                                                    ''),
                                                          ),
                                                          // Container(
                                                          //   height: 2,
                                                          //   width: 8,
                                                          //   color: progresoRuta >
                                                          //           3
                                                          //       ? Colors.amber
                                                          //       : const Color
                                                          //               .fromARGB(
                                                          //           255,
                                                          //           214,
                                                          //           214,
                                                          //           214),
                                                          // ),
                                                          // Container(
                                                          //   width: 14,
                                                          //   height: 14,
                                                          //   decoration: BoxDecoration(
                                                          //       borderRadius:
                                                          //           BorderRadius
                                                          //               .circular(
                                                          //                   14),
                                                          //       border: Border.all(
                                                          //           width: 2,
                                                          //           color: progresoRuta >=
                                                          //                   4
                                                          //               ? Colors
                                                          //                   .amber
                                                          //               : const Color.fromARGB(
                                                          //                   255,
                                                          //                   214,
                                                          //                   214,
                                                          //                   214)),
                                                          //       color: progresoRuta >
                                                          //               4
                                                          //           ? Colors
                                                          //               .amber
                                                          //           : Colors
                                                          //               .white),
                                                          //   child: progresoRuta >
                                                          //           4
                                                          //       ? const Icon(
                                                          //           Icons.check,
                                                          //           color: Color
                                                          //               .fromARGB(
                                                          //                   255,
                                                          //                   255,
                                                          //                   255,
                                                          //                   255),
                                                          //           size: 10,
                                                          //         )
                                                          //       : const Text(
                                                          //           ''),
                                                          // ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(nombreViajeenCurso,
                                                          style: const TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      21,
                                                                      21,
                                                                      21,
                                                                      1),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(
                                                        '$distritoinicio, $inicio - $distritofin, $fin',
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    141,
                                                                    141,
                                                                    141),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons
                                                      .keyboard_arrow_right_rounded,
                                                )
                                              ],
                                            ),
                                          )
                                        : MaterialButton(
                                            height: 60,
                                            onPressed: () async {
                                              // buscadorModalLevantar();
                                              //   if(salida_lat != '' && salida_long != '' && destino_lat != '' && destino_long != ''){
                                              // }
                                              Navigator.of(context).push(
                                                  CupertinoPageRoute<void>(
                                                      builder: (BuildContext
                                                          context) {
                                                return const RutasRecomendadas();
                                              }));
                                            },
                                            elevation: 0,
                                            splashColor: Colors.transparent,
                                            child: Row(
                                              children: const [
                                                Icon(
                                                  Icons.search,
                                                  color: Color.fromARGB(
                                                      255, 131, 131, 131),
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text('¿A dónde vamos?',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color.fromARGB(
                                                            255,
                                                            131,
                                                            131,
                                                            131))),
                                              ],
                                            ),
                                          )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ]);
  }
}
