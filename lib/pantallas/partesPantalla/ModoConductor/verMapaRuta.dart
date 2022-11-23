import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miruta/lista_de_pantalla.dart';
import 'package:http/http.dart' as http;

class VerMapa extends StatefulWidget {
  final String idRuta;
  final String origen;
  final bool viajeEnCurso;
  final String salida_lat;
  final String salida_long;
  final String destino_lat;
  final String destino_long;
  final String nombreRutaController;
  final String recogermosControlerNombre;
  final String llegasControladorNombre;
  final String direccionInicial;
  final String direccionFinal;
  final String distritoInicial;
  final String distritoFinal;
  final String provinciaInicial;
  final String provinciaFinal;
  final String regionInicial;
  final String regionFinal;
  final String direccionExactaInicial;
  final String direccionExactaFinal;

  const VerMapa(
      {Key? key,
      required this.idRuta,
      required this.origen,
      required this.viajeEnCurso,
      required this.salida_lat,
      required this.salida_long,
      required this.destino_lat,
      required this.destino_long,
      required this.nombreRutaController,
      required this.recogermosControlerNombre,
      required this.llegasControladorNombre,
      required this.direccionInicial,
      required this.direccionFinal,
      required this.distritoInicial,
      required this.distritoFinal,
      required this.provinciaInicial,
      required this.provinciaFinal,
      required this.regionInicial,
      required this.regionFinal,
      required this.direccionExactaInicial,
      required this.direccionExactaFinal})
      : super(key: key);

  @override
  State<VerMapa> createState() => _VerMapaState();
}

class _VerMapaState extends State<VerMapa> {
  late GoogleMapController _googleMapController;
  final Completer<GoogleMapController> _googlemapsControlador = Completer();
  final Set<Polyline> _polylines = <Polyline>{};
  final Set<Marker> _markers = <Marker>{};
  bool buscandoDataRuta = false, rutaConAsientos = false, cancelarRuta = false;

  double latitudInicial = 0,
      longitudInicial = 0,
      latitudFinal = 0,
      longitudFinal = 0;

  String estadoRuta = '';

  String distancia = '-',
      tiempo = '-',
      precio = '-',
      nombreViaje = '-',
      ubicacionViaje = '',
      direccionInicioReal = '',
      direccionFinReal = '',
      direccionInicioRealCompleta = '',
      direccionFinRealCompleta = '',
      nombreEstadoRuta = '-',
      asientosTotales = '',
      asientosOcupados = '',
      idConductor = '';

  late BitmapDescriptor inicioMarker;
  late BitmapDescriptor finMarker;
  late BitmapDescriptor puntos;
  late BitmapDescriptor marco;
  late BitmapDescriptor marcob;

  int misMensajes = 0;

  void hacerRuta(List<PointLatLng> puntos) {
    String polulineId = 'polyline_${widget.idRuta}';

    _polylines.add(Polyline(
        polylineId: PolylineId(polulineId),
        width: 5,
        color: Colors.amber,
        points: puntos
            .map((punto) => LatLng(punto.latitude, punto.longitude))
            .toList()));
  }

  Future<void> realTimeInfoRuta() async {
    const storage = FlutterSecureStorage();
    String? value = await storage.read(key: 'SESSION');
    Map<String, dynamic> usuarioResponse = json.decode(value ?? '');
    dynamic idChofer = usuarioResponse['iIdChofer'];
    FirebaseFirestore.instance
        .collection('busquedas')
        .doc('cambio')
        .snapshots()
        .listen((event) {
      listarInfoRuta_sincarga();
    });
  }

  verCambiosSolicitudes() async {
    FirebaseFirestore.instance
        .collection("solicitudes")
        .doc(widget.idRuta)
        .snapshots()
        .listen((event) async {
      dynamic res = await Lib().listarSolicitudesxidRuta(widget.idRuta) ?? 0;
      listarInfoRuta_sincarga();
      if (mounted) {
        setState(() {
          misMensajes = res.length;
        });
      }
    });
  }

  Future<void> _dirigirCamara(double latInicial, double longInicial,
      Map<String, dynamic> vistaNorte, Map<String, dynamic> vistaSur) async {
    final GoogleMapController controller = await _googlemapsControlador.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(latInicial, latInicial), zoom: 14)),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: LatLng(vistaSur['lat'], vistaSur['lng']),
              northeast: LatLng(vistaNorte['lat'], vistaNorte['lng'])),
          100),
    );
  }

  Future<void> listarInfoRuta() async {
    setState(() {
      buscandoDataRuta = true;
    });
    dynamic res = await Lib().listarRutaid(widget.idRuta);
    dynamic rutasPasajeros = await Lib().listarMisRutasPasajeros(widget.idRuta);
    List<dynamic> misPuntos = [];
    if (res.length > 0) {
      dynamic miCamino;
      dynamic miCaminoD;

      // aqui pintar puntos
      miCaminoD = await Lib().obtenerRuta(
          '${res[0]['vchLatInicial']},${res[0]['vchLongInicial']}',
          '${res[0]['vchLatFinal']},${res[0]['vchLongFinal']}');
      // aqui pintar puntos
      if (rutasPasajeros.length > 0) {
        for (int i = 0; i < rutasPasajeros.length; i++) {
          misPuntos.add(
              '${rutasPasajeros[i]['vchLatInicial']},${rutasPasajeros[i]['vchLongInicial']}');
          misPuntos.add(
              '${rutasPasajeros[i]['vchLatFinal']},${rutasPasajeros[i]['vchLongFinal']}');
        }
        miCamino = await Lib().obtenerRutaConPuntosUsuarios(
            '${res[0]['vchLatInicial']},${res[0]['vchLongInicial']}',
            '${res[0]['vchLatFinal']},${res[0]['vchLongFinal']}',
            misPuntos.join('|'));
      } else {
        miCamino = await Lib().obtenerRuta(
            '${res[0]['vchLatInicial']},${res[0]['vchLongInicial']}',
            '${res[0]['vchLatFinal']},${res[0]['vchLongFinal']}');
      }

      print(res);
      if (mounted) {
        setState(() {
          idConductor = res[0]['iIdVehiculo'];
        });
      }

      _dirigirCamara(
        double.parse(res[0]['vchLatInicial']),
        double.parse(res[0]['vchLongInicial']),
        miCamino['routes'][0]['bounds']['northeast'],
        miCamino['routes'][0]['bounds']['southwest'],
      );

      dynamic misRutasDocificada = PolylinePoints()
          .decodePolyline(miCamino['routes'][0]['overview_polyline']['points']);
      hacerRuta(misRutasDocificada);

// vchUrlImage

      inicioMarker = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'assets/images/png/iconos/a.png');

      finMarker = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'assets/images/png/iconos/b.png');

      _agregaMarkador(
          inicioMarker,
          'Inicio',
          LatLng(
              miCaminoD['routes'][0]['legs'][0]['steps'][0]['start_location']
                  ['lat'],
              miCaminoD['routes'][0]['legs'][0]['steps'][0]['start_location']
                  ['lng']));
      _agregaMarkador(
          finMarker,
          'Fin',
          LatLng(
              miCaminoD['routes'][0]['legs'][0]['steps']
                      [miCaminoD['routes'][0]['legs'][0]['steps'].length - 1]
                  ['end_location']['lat'],
              miCaminoD['routes'][0]['legs'][0]['steps']
                      [miCaminoD['routes'][0]['legs'][0]['steps'].length - 1]
                  ['end_location']['lng']));
      // _agregaMarkador('Fin',LatLng(double.parse(res[0]['vchLatFinal'], longitude));

      if (rutasPasajeros.length > 0) {
        for (int i = 0; i < rutasPasajeros.length; i++) {
          misPuntos.add(
              '${rutasPasajeros[i]['vchLatInicial']},${rutasPasajeros[i]['vchLongInicial']}');
          misPuntos.add(
              '${rutasPasajeros[i]['vchLatFinal']},${rutasPasajeros[i]['vchLongFinal']}');

          // print(rutasPasajeros);

          Uri imageUrl = Uri.parse(rutasPasajeros[i]['vchUrlImage'] ??
              'https://res.cloudinary.com/jrdotcom/image/upload/v1668389036/miRuta/s_rvhwte.png');
          http.Response response = await http.get(imageUrl);
          dynamic originalUnit8List = response.bodyBytes;

          ui.Image originalUiImage =
              await decodeImageFromList(originalUnit8List);
          var codec = await ui.instantiateImageCodec(originalUnit8List,
              targetHeight: 67, targetWidth: 67);
          var frameInfo = await codec.getNextFrame();
          ui.Image targetUiImage = frameInfo.image;
          ByteData? targetByteData =
              await targetUiImage.toByteData(format: ui.ImageByteFormat.png);
          dynamic targetlUinit8List = targetByteData!.buffer.asUint8List();
          puntos = BitmapDescriptor.fromBytes(targetlUinit8List);

          marco = await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(), 'assets/images/png/iconos/sa.png');
          marcob = await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(), 'assets/images/png/iconos/sb.png');

          //  inicio
          _agregaMarkadorUsuariosFoto(
              puntos,
              'Inicio',
              LatLng(double.parse(rutasPasajeros[i]['vchLatInicial']),
                  double.parse(rutasPasajeros[i]['vchLongInicial'])));
          _agregaMarkador(
              marco,
              'User',
              LatLng(double.parse(rutasPasajeros[i]['vchLatInicial']),
                  double.parse(rutasPasajeros[i]['vchLongInicial'])));
          // rutasPasajeros[i]['vchLatFinal'],
          // rutasPasajeros[i]['vchLongFinal']));

          // fin
          _agregaMarkadorUsuariosFoto(
              puntos,
              'Inicio',
              LatLng(double.parse(rutasPasajeros[i]['vchLatFinal']),
                  double.parse(rutasPasajeros[i]['vchLongFinal'])));
          _agregaMarkador(
              marcob,
              'User',
              LatLng(double.parse(rutasPasajeros[i]['vchLatFinal']),
                  double.parse(rutasPasajeros[i]['vchLongFinal'])));
        }
        //  miCamino = await Lib().obtenerRutaConPuntosUsuarios(
        //   '${res[0]['vchLatInicial']},${res[0]['vchLongInicial']}',
        //   '${res[0]['vchLatFinal']},${res[0]['vchLongFinal']}',misPuntos.join('|'));
      }

      print('hhhhhhhhhhhhhhhhhhh');
      print(res);
      if (mounted) {
        dynamic miTiempoTotal = 0;
        dynamic miDistanciaTotal = 0;
        dynamic miRes = miCamino['routes'][0]['legs'];
        for (int i = 0; i < miRes.length; i++) {
          miTiempoTotal = miTiempoTotal + miRes[i]['distance']['value'];
          miDistanciaTotal = miDistanciaTotal + miRes[i]['duration']['value'];
        }
        if (miDistanciaTotal >= 1000) {
          miDistanciaTotal = ((miDistanciaTotal / 1000).floor()).toString() +
              'km ' +
              (miDistanciaTotal % 1000).toString() +
              'm';
        } else {
          miDistanciaTotal = (miDistanciaTotal).toString() + ' m';
        }

        if (miTiempoTotal >= 3600) {
          miTiempoTotal = (miTiempoTotal / 3600).floor().toString() +
              'h  ' +
              (miTiempoTotal % 60).toString() +
              'min';
        } else {
          miTiempoTotal = (miTiempoTotal % 60).floor().toString() + 'min';
        }

        setState(() {
          distancia = miDistanciaTotal;
          // distancia = miCamino['routes'][0]['legs'][0]['distance']['text'];
          tiempo = miTiempoTotal;
          // tiempo = miCamino['routes'][0]['legs'][0]['duration']['text'];
          precio = double.parse(res[0]['mPrecio']).toStringAsFixed(2);
          nombreViaje = res[0]['name'];
          ubicacionViaje =
              '${res[0]['vchRegionInicial'] ?? 'N/A'} - ${res[0]['vchRegionFinal'] ?? 'N/A'}';
          buscandoDataRuta = false;
          direccionInicioReal = res[0]['vDetalleNombreInicio'] ?? 'N/A';
          direccionFinReal = res[0]['vDetalleNombreFin'] ?? 'N/A';
          direccionInicioRealCompleta =
              res[0]['vDireccionExactaInicio'] ?? 'N/A';
          direccionFinRealCompleta = res[0]['vDireccionExactaFin'] ?? 'N/A';
          latitudInicial = double.parse(res[0]['vchLatInicial']);
          longitudInicial = double.parse(res[0]['vchLongInicial']);
          latitudFinal = double.parse(res[0]['vchLatFinal']);
          longitudFinal = double.parse(res[0]['vchLongFinal']);
          estadoRuta = res[0]['EstadoServicio'].trim();
          asientosTotales = res[0]['asientos'];
          asientosOcupados = res[0]['asientosOcupados'];
          rutaConAsientos = true;
        });
      }

      switch (res[0]['EstadoServicio'].trim()) {
        case 'CREADO':
          setState(() {
            nombreEstadoRuta = 'Viaje listo';
          });
          break;
        case 'EN_PARADERO':
          setState(() {
            nombreEstadoRuta = 'Viaje en paradero';
          });
          break;
        case 'EN_RUTA':
          setState(() {
            nombreEstadoRuta = 'Viaje en curso';
          });
          break;
        case 'FINALIZADO':
          setState(() {
            nombreEstadoRuta = 'Viaje finalizado';
          });
          break;
        case 'TERMINADO':
          setState(() {
            nombreEstadoRuta = 'Viaje terminado';
          });
          break;
        case 'NO_DISPONIBLE':
          setState(() {
            nombreEstadoRuta = 'Viaje no disponible';
          });
          break;
        default:
          setState(() {
            nombreEstadoRuta = 'Viaje listo';
          });
          break;
      }
    } else {
      dynamic res = await Lib().listarRutaidSiNoExiste(widget.idRuta);
      print(res);
      dynamic miCamino = await Lib().obtenerRuta(
          '${res[0]['vchLatInicial']},${res[0]['vchLongInicial']}',
          '${res[0]['vchLatFinal']},${res[0]['vchLongFinal']}');
      if (mounted) {
        setState(() {
          idConductor = res[0]['iIdVehiculo'];
        });
      }
      _dirigirCamara(
        double.parse(res[0]['vchLatInicial']),
        double.parse(res[0]['vchLongInicial']),
        miCamino['routes'][0]['bounds']['northeast'],
        miCamino['routes'][0]['bounds']['southwest'],
      );

      dynamic misRutasDocificada = PolylinePoints()
          .decodePolyline(miCamino['routes'][0]['overview_polyline']['points']);
      hacerRuta(misRutasDocificada);

      inicioMarker = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'assets/images/png/iconos/a.png');

      finMarker = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'assets/images/png/iconos/b.png');

      _agregaMarkador(
          inicioMarker,
          'Inicio',
          LatLng(
              miCamino['routes'][0]['legs'][0]['steps'][0]['start_location']
                  ['lat'],
              miCamino['routes'][0]['legs'][0]['steps'][0]['start_location']
                  ['lng']));
      _agregaMarkador(
          finMarker,
          'Fin',
          LatLng(
              miCamino['routes'][0]['legs'][0]['steps']
                      [miCamino['routes'][0]['legs'][0]['steps'].length - 1]
                  ['end_location']['lat'],
              miCamino['routes'][0]['legs'][0]['steps']
                      [miCamino['routes'][0]['legs'][0]['steps'].length - 1]
                  ['end_location']['lng']));
      // _agregaMarkador('Fin',LatLng(double.parse(res[0]['vchLatFinal'], longitude));

      print('hhhhhhhhhhhhhhhhhhh');
      print(res);
      setState(() {
        distancia = miCamino['routes'][0]['legs'][0]['distance']['text'];
        tiempo = miCamino['routes'][0]['legs'][0]['duration']['text'];
        precio = double.parse(res[0]['mPrecio']).toStringAsFixed(2);
        nombreViaje = res[0]['name'];
        ubicacionViaje =
            '${res[0]['vchRegionInicial'] ?? 'N/A'} - ${res[0]['vchRegionFinal'] ?? 'N/A'}';
        buscandoDataRuta = false;
        direccionInicioReal = res[0]['vDetalleNombreInicio'] ?? 'N/A';
        direccionFinReal = res[0]['vDetalleNombreFin'] ?? 'N/A';
        direccionInicioRealCompleta = res[0]['vDireccionExactaInicio'] ?? 'N/A';
        direccionFinRealCompleta = res[0]['vDireccionExactaFin'] ?? 'N/A';
        latitudInicial = double.parse(res[0]['vchLatInicial']);
        longitudInicial = double.parse(res[0]['vchLongInicial']);
        latitudFinal = double.parse(res[0]['vchLatFinal']);
        longitudFinal = double.parse(res[0]['vchLongFinal']);
        estadoRuta = 'NINGUNO';
        asientosTotales = '0';
        asientosOcupados = '0';
        nombreEstadoRuta = 'Viaje creado';
        rutaConAsientos = false;
      });
    }
  }

  Future<void> listarInfoRuta_sincarga() async {
    dynamic res = await Lib().listarRutaid(widget.idRuta);
    if (res.length > 0) {
      print(res);

      print('hhhhhhhhhhhhhhhhhhh');
      print(res);
      if (mounted) {
        setState(() {
          estadoRuta = res[0]['EstadoServicio'].trim();
          asientosTotales = res[0]['asientos'];
          asientosOcupados = res[0]['asientosOcupados'];
          rutaConAsientos = true;
        });
      }

      switch (res[0]['EstadoServicio'].trim()) {
        case 'CREADO':
          if (mounted) {
            setState(() {
              nombreEstadoRuta = 'Viaje listo';
            });
          }
          break;
        case 'EN_PARADERO':
          if (mounted) {
            setState(() {
              nombreEstadoRuta = 'Viaje en paradero';
            });
          }
          break;
        case 'EN_RUTA':
          if (mounted) {
            setState(() {
              nombreEstadoRuta = 'Viaje en curso';
            });
          }
          break;
        case 'FINALIZADO':
          if (mounted) {
            setState(() {
              nombreEstadoRuta = 'Viaje finalizado';
            });
          }
          break;
        case 'TERMINADO':
          if (mounted) {
            setState(() {
              nombreEstadoRuta = 'Viaje terminado';
            });
          }
          break;
        case 'NO_DISPONIBLE':
          if (mounted) {
            setState(() {
              nombreEstadoRuta = 'Viaje no disponible';
            });
          }
          break;
        default:
          if (mounted) {
            setState(() {
              nombreEstadoRuta = 'Viaje listo';
            });
          }
          break;
      }
    } else {
      dynamic res = await Lib().listarRutaidSiNoExiste(widget.idRuta);
      print(res);

      print('hhhhhhhhhhhhhhhhhhh');
      print(res);
      if (mounted) {
        setState(() {
          estadoRuta = 'NINGUNO';
          asientosTotales = '0';
          asientosOcupados = '0';
          nombreEstadoRuta = 'Viaje creado';
          rutaConAsientos = false;
        });
      }
    }
    // if (res.length > 0) {
    //   if (mounted) {
    //     setState(() {
    //       estadoRuta = res[0]['EstadoServicio'].trim();
    //       asientosTotales = res[0]['asientos'];
    //       asientosOcupados = res[0]['asientosOcupados'];

    //       if (estadoRuta == 'FINALIZADO' && widget.origen == 'PASAJERO') {
    //         Navigator.of(context).pushAndRemoveUntil(
    //             CupertinoPageRoute<void>(builder: (BuildContext context) {
    //           return Rating_pasajero(idRuta: widget.idRuta, idUsuario: '1');
    //         }), (Route<dynamic> route) => false);
    //       }

    //       if (estadoRuta == 'EN_PARADERO' ||
    //           estadoRuta == 'EN_RUTA' ||
    //           estadoRuta == 'FINALIZADO') {
    //         setState(() {
    //           rutaConAsientos = true;
    //         });
    //       }

    //       switch (res[0]['EstadoServicio'].trim()) {
    //         case 'CREADO':
    //           setState(() {
    //             nombreEstadoRuta = 'Viaje listo';
    //           });
    //           break;
    //         case 'EN_PARADERO':
    //           setState(() {
    //             nombreEstadoRuta = 'Viaje en paradero';
    //           });
    //           break;
    //         case 'EN_RUTA':
    //           setState(() {
    //             nombreEstadoRuta = 'Viaje en curso';
    //           });
    //           break;
    //         case 'FINALIZADO':
    //           setState(() {
    //             nombreEstadoRuta = 'Viaje finalizado';
    //           });
    //           break;
    //         case 'TERMINADO':
    //           setState(() {
    //             nombreEstadoRuta = 'Viaje terminado';
    //           });
    //           break;
    //         case 'NO_DISPONIBLE':
    //           setState(() {
    //             nombreEstadoRuta = 'Viaje no disponible';
    //           });
    //           break;
    //         default:
    //           break;
    //       }
    //     });
    //   }
    // }
  }

  void _agregaMarkador(BitmapDescriptor icon, String idMrcador, LatLng puntos) {
    if (mounted) {
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId(idMrcador), position: puntos, icon: icon));
      });
    }
  }

  void _agregaMarkadorUsuariosFoto(
      BitmapDescriptor icon, String idMrcador, LatLng puntos) {
    if (mounted) {
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId(idMrcador),
            position: puntos,
            icon: icon,
            anchor: const ui.Offset(0.5, 1.27)));
      });
    }
  }

  Widget verbotonOpcionestadoRuta(estadoRuta, miidRuta) {
    switch (estadoRuta.trim()) {
      case 'CREADO':
        return opcionesCrearNuevaRuta(
            idRuta: miidRuta,
            nombre: nombreViaje,
            distancia: distancia,
            precio: precio,
            tiempo: tiempo);
      case 'EN_PARADERO':
        return opcionesEnParadero(idRuta: miidRuta, nombre: nombreViaje);
      case 'EN_RUTA':
        return opcionesRutaEnCurso(idRuta: miidRuta, nombre: nombreViaje);
      case 'FINALIZADO':
        return opcionesCrearNuevaRuta(
            idRuta: miidRuta,
            nombre: nombreViaje,
            distancia: distancia,
            precio: precio,
            tiempo: tiempo);
      case 'TERMINADO':
        return opcionesCrearNuevaRuta(
            idRuta: miidRuta,
            nombre: nombreViaje,
            distancia: distancia,
            precio: precio,
            tiempo: tiempo);
      case 'NO_DISPONIBLE':
        return opcionesCrearNuevaRuta(
            idRuta: miidRuta,
            nombre: nombreViaje,
            distancia: distancia,
            precio: precio,
            tiempo: tiempo);
      default:
        return opcionesCrearNuevaRuta(
            idRuta: miidRuta,
            nombre: nombreViaje,
            distancia: distancia,
            precio: precio,
            tiempo: tiempo);
    }
  }

  Widget verbotonOpcionesPasajero(estadoRuta, miidRuta) {
    switch (estadoRuta.trim()) {
      case 'CREADO':
        return const SizedBox(
          width: 0,
        );
      case 'EN_PARADERO':
        return opcionesEnParaderoUsuario(
            idRutaM: miidRuta,
            nombre: nombreViaje,
            salida_lat: widget.salida_lat,
            salida_long: widget.salida_long,
            destino_lat: widget.destino_lat,
            destino_long: widget.destino_long,
            nombreRutaController: widget.nombreRutaController,
            recogermosControlerNombre: widget.recogermosControlerNombre,
            llegasControladorNombre: widget.llegasControladorNombre,
            direccionInicial: widget.direccionInicial,
            direccionFinal: widget.direccionFinal,
            distritoInicial: widget.distritoInicial,
            distritoFinal: widget.distritoFinal,
            provinciaInicial: widget.provinciaInicial,
            provinciaFinal: widget.provinciaFinal,
            regionInicial: widget.regionInicial,
            regionFinal: widget.regionFinal,
            direccionExactaInicial: widget.direccionExactaInicial,
            direccionExactaFinal: widget.direccionExactaFinal);
      case 'EN_RUTA':
        return opcionesEnParaderoUsuario(
            idRutaM: miidRuta,
            nombre: nombreViaje,
            salida_lat: widget.salida_lat,
            salida_long: widget.salida_long,
            destino_lat: widget.destino_lat,
            destino_long: widget.destino_long,
            nombreRutaController: widget.nombreRutaController,
            recogermosControlerNombre: widget.recogermosControlerNombre,
            llegasControladorNombre: widget.llegasControladorNombre,
            direccionInicial: widget.direccionInicial,
            direccionFinal: widget.direccionFinal,
            distritoInicial: widget.distritoInicial,
            distritoFinal: widget.distritoFinal,
            provinciaInicial: widget.provinciaInicial,
            provinciaFinal: widget.provinciaFinal,
            regionInicial: widget.regionInicial,
            regionFinal: widget.regionFinal,
            direccionExactaInicial: widget.direccionExactaInicial,
            direccionExactaFinal: widget.direccionExactaFinal);
      case 'FINALIZADO':
        return const SizedBox(
          width: 0,
        );
      case 'TERMINADO':
        return const SizedBox(
          width: 0,
        );
      case 'NO_DISPONIBLE':
        return const SizedBox(
          width: 0,
        );
      default:
        return const SizedBox(
          width: 0,
        );
    }
  }

  @override
  void initState() {
    listarInfoRuta();
    verCambiosSolicitudes();
    realTimeInfoRuta();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _camarainicial = CameraPosition(
        target: LatLng(latitudInicial, longitudInicial), zoom: 7.0);
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
          title: Text(
            nombreEstadoRuta,
            style: const TextStyle(fontSize: 12),
          ),
          centerTitle: true,
          actions: <Widget>[
            widget.origen == 'CONDUCTOR'
                ? IconButton(
                    onPressed: () => {
                      Navigator.of(context).push(CupertinoPageRoute<void>(
                          builder: (BuildContext context) {
                        return SolicitudDeAsiento(
                          idRuta: widget.idRuta,
                          origen: widget.origen,
                        );
                      }))
                    },
                    icon: Badge(
                      badgeColor: Colors.blueAccent,
                      position: BadgePosition.topEnd(),
                      showBadge: misMensajes > 0 ? true : false,
                      animationDuration: const Duration(milliseconds: 250),
                      badgeContent: Text(
                        '$misMensajes',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        color: Colors.amber,
                      ),
                    ),
                  )
                : const SizedBox(
                    height: 0,
                  ),
            widget.origen == 'CONDUCTOR'
                ? IconButton(
                    onPressed: () => {
                      Navigator.of(context).push(CupertinoPageRoute<void>(
                          builder: (BuildContext context) {
                        return Asientos(
                          idRuta: widget.idRuta,
                          origen: widget.origen,
                        );
                      }))
                    },
                    icon: const Icon(
                      Icons.group_outlined,
                      color: Colors.amber,
                    ),
                  )
                : const SizedBox(
                    height: 0,
                  ),
            widget.origen == 'PASAJERO'
                ? idConductor == ''
                    ? const Text('-')
                    : TextButton(
                        onPressed: () {
                          Navigator.of(context).push(CupertinoPageRoute<void>(
                              builder: (BuildContext context) {
                            return InformacionConductor(
                                idConductor: idConductor);
                          }));
                        },
                        child: const Icon(
                          Icons.badge_outlined,
                          color: Colors.amber,
                        ),
                      )
                : const SizedBox(
                    height: 0,
                  ),
          ],
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
              ),
              onPressed: () => Navigator.of(context).pop(),
            );
          })),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(children: [
                buscandoDataRuta
                    ? const Center(child: CupertinoActivityIndicator())
                    : GoogleMap(
                        initialCameraPosition: _camarainicial,
                        onMapCreated: (GoogleMapController controller) {
                          controller.setMapStyle(MapaDisenio.miMapa);
                          // _googleMapController = controller;
                          _googlemapsControlador.complete(controller);
                          // setState(() {
                          //   cargaControladorMapa = true;
                          // });
                          // Lib().obtenerUbicacionInicial(_googleMapController);
                        },
                        markers: _markers,
                        polylines: _polylines,
                        compassEnabled: false,
                        myLocationButtonEnabled: false,
                        rotateGesturesEnabled: true,
                        myLocationEnabled: false,
                        zoomControlsEnabled: false,
                        onTap: (position) {},
                        onCameraMove: (CameraPosition position) {
                          // streamLatitud.add(position.target.latitude);
                          // streamLogintud.add(position.target.longitude);
                        },
                        onCameraIdle: () {
                          // setState(() {
                          //   moviendoPin = false;
                          //   buscandoUbicacionNombre = true;
                          // });

                          // obtenerLatitudLongitud();
                        },
                        onCameraMoveStarted: () {
                          // setState(() {
                          //   moviendoPin = true;
                          // });
                          // ocultarElementosdeVentada();
                        }),
                // Mapa_usuario_medio_pantalla(imagenPerfil: imagenPerfil),
                // Mapa_popup_nombre_calles(
                //     moviendoPin: moviendoPin,
                //     buscandoUbicacionNombre: buscandoUbicacionNombre,
                //     miLugar: miLugar),
                // cargaControladorMapa
                //     ? Mapa_boton_ubicacion_actual(
                //         inicioBotonMiUbicacion: _inicioBotonMiUbicacion,
                //         mapaControlador: _googleMapController)
                //     : const SizedBox(
                //         width: 0,
                //       ),
                // Mapa_fondo_a_donde_vamos(posicionBuscador: posicionBuscador),
                AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.fastOutSlowIn,
                    left: 10,
                    right: 10,
                    top: 90,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromARGB(255, 255, 255, 255),
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromARGB(20, 0, 0, 0),
                                blurRadius: 10,
                                spreadRadius: 1),
                          ]),

                      // height: 100,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4, top: 2),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              minVerticalPadding: 1,
                              visualDensity: VisualDensity.compact,
                              horizontalTitleGap: 8,
                              dense: true,
                              title: Text(direccionInicioReal,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  softWrap: false),
                              subtitle: Text(direccionInicioRealCompleta,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false),
                              leading: Padding(
                                padding: const EdgeInsets.only(left: 6, top: 4),
                                child: Transform.scale(
                                  scale: 0.8,
                                  child: const IconoPinTextodentro(
                                      textoIcono: 'A'),
                                ),
                              ),
                            ),
                            Container(
                              height: 4,
                            ),
                            Container(
                                height: 1,
                                color:
                                    const Color.fromARGB(255, 241, 241, 241)),
                            ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              minVerticalPadding: 1,
                              visualDensity: VisualDensity.compact,
                              horizontalTitleGap: 8,
                              dense: true,
                              title: Text(direccionFinReal,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.fade,
                                  maxLines: 2,
                                  softWrap: false),
                              subtitle: Text(direccionFinRealCompleta,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false),
                              leading: Padding(
                                padding: const EdgeInsets.only(left: 6, top: 4),
                                child: Transform.scale(
                                  scale: 0.8,
                                  child: const IconoPinTextodentro(
                                      textoIcono: 'B'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                widget.origen == 'CONDUCTOR'
                    ? AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.fastOutSlowIn,
                        bottom: 180,
                        left: 10,
                        child: GestureDetector(
                          onTap: () {
                            if (estadoRuta.trim() == 'EN_PARADERO' ||
                                estadoRuta.trim() == 'EN_RUTA') {
                              showDialog<void>(
                                  context: context, // user must tap button!
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Cancelar el viaje',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      ),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: const <Widget>[
                                            Text(
                                              '¿Deseas cancelar el viaje creado y dejar de mostrar tu viaje a los usuarios?',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      128, 21, 21, 21)),
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
                                                    fontSize: 14,
                                                    color: Color.fromARGB(
                                                        255, 28, 28, 28)),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: const Color.fromRGBO(
                                                  21, 21, 21, 1),
                                            ),
                                            child: TextButton(
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Sí, cancelar',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              onPressed: () async {
                                                final miSalidaAParadero =
                                                    await Lib().cancelarViaje(
                                                        int.parse(
                                                            widget.idRuta));
                                                if (miSalidaAParadero) {
                                                  const storage =
                                                      FlutterSecureStorage();
                                                  String? value = await storage
                                                      .read(key: 'SESSION');
                                                  Map<String, dynamic>
                                                      usuarioResponse =
                                                      json.decode(value ?? '');
                                                  dynamic idChofer =
                                                      usuarioResponse[
                                                          'iIdChofer'];
                                                  Random random = Random();
                                                  int randomNumber =
                                                      random.nextInt(10000);
                                                  int randomNumberB =
                                                      random.nextInt(10000);

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('movimientos')
                                                      .doc(idChofer)
                                                      .set({
                                                    'random': randomNumber
                                                  });

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('busquedas')
                                                      .doc('cambio')
                                                      .set({
                                                    'random': randomNumberB
                                                  });
                                                  Navigator.of(context).pop();
                                                  showTopSnackBar(
                                                    context,
                                                    const CustomSnackBar
                                                        .success(
                                                      message:
                                                          "Viaje cancelado correctamente",
                                                    ),
                                                  );
                                                  Navigator.of(context)
                                                      .pushAndRemoveUntil(
                                                          CupertinoPageRoute<
                                                                  void>(
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                    return const Menu();
                                                  }),
                                                          (Route<dynamic>
                                                                  route) =>
                                                              false);
                                                } else {
                                                  showTopSnackBar(
                                                    context,
                                                    const CustomSnackBar.error(
                                                      message:
                                                          "Lo sentimos, hubo un error, inténtalo nuevamente",
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              showTopSnackBar(
                                context,
                                const CustomSnackBar.error(
                                  message:
                                      "Solo se puede cancelar el viaje cuando estás en paradero",
                                ),
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color: estadoRuta.trim() == 'EN_PARADERO' ||
                                      estadoRuta.trim() == 'EN_RUTA'
                                  //  || estadoRuta.trim()=='EN_RUTA'
                                  ? Colors.amber
                                  : const Color.fromARGB(255, 214, 214, 214),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Text('Cancelar viaje',
                                    style: TextStyle(
                                        color:
                                            estadoRuta.trim() == 'EN_PARADERO'
                                                ? Colors.black
                                                : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                widget.origen == 'CONDUCTOR'
                    ? verbotonOpcionestadoRuta(estadoRuta, widget.idRuta)
                    : const SizedBox(
                        width: 0,
                      ),
                widget.origen == 'PASAJERO'
                    ? widget.viajeEnCurso
                        ? Container()
                        : verbotonOpcionesPasajero(estadoRuta, widget.idRuta)
                    : const SizedBox(
                        width: 0,
                      ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.fastOutSlowIn,
                  left: 10,
                  right: 10,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      color: Color.fromRGBO(255, 255, 255, 0),
                    ),
                    // width: MediaQuery.of(context).size.width * 0.5,
                    height: 110,
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
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 4),
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: Text(
                                        nombreViaje,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                              distancia,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromRGBO(
                                                      21, 21, 21, 1),
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Clan'),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                              tiempo,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromRGBO(
                                                      21, 21, 21, 1),
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Clan'),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              rutaConAsientos
                                                  ? 'Asientos'
                                                  : 'Asientos',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Clan'),
                                            ),
                                            Text(
                                              rutaConAsientos
                                                  ? '$asientosOcupados / $asientosTotales'
                                                  : '0/0',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromRGBO(
                                                      21, 21, 21, 1),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ]),
    );
  }
}

class opcionesCrearNuevaRuta extends StatelessWidget {
  const opcionesCrearNuevaRuta({
    Key? key,
    required this.idRuta,
    required this.nombre,
    required this.distancia,
    required this.tiempo,
    required this.precio,
  }) : super(key: key);
  final String idRuta;
  final String nombre;
  final String distancia;
  final String tiempo;
  final String precio;
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      left: 10,
      right: 10,
      bottom: 110,
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
                  color: const Color.fromRGBO(31, 31, 31, 1),
                  child: MaterialButton(
                    height: 60,
                    onPressed: () {
                      Navigator.of(context).push(CupertinoPageRoute<void>(
                          builder: (BuildContext context) {
                        return GestionEstadoRuta(
                            nombreViaje: nombre,
                            distancia: distancia,
                            tiempo: tiempo,
                            precio: precio,
                            idRuta: idRuta);
                      }));
                    },
                    elevation: 0,
                    splashColor: const Color.fromRGBO(31, 31, 31, 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 0,
                        ),
                        Text('Iniciar el viaje',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class opcionesRutaEnCurso extends StatefulWidget {
  const opcionesRutaEnCurso({
    Key? key,
    required this.idRuta,
    required this.nombre,
  }) : super(key: key);
  final String idRuta;
  final String nombre;

  @override
  State<opcionesRutaEnCurso> createState() => _opcionesRutaEnCursoState();
}

class _opcionesRutaEnCursoState extends State<opcionesRutaEnCurso> {
  bool cargandoRuta = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      left: 10,
      right: 10,
      bottom: 110,
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
                  color: const Color.fromRGBO(31, 31, 31, 1),
                  child: MaterialButton(
                    height: 60,
                    onPressed: () {
                      showDialog<void>(
                          context: context, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                'Terminar el viaje',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: const <Widget>[
                                    Text(
                                      '¿Deseas terminar el viaje? Asegurate dque los pasajeros no dejen sus pertenencias en el vehícuo',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromARGB(128, 21, 21, 21)),
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
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 28, 28, 28)),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          const Color.fromRGBO(21, 21, 21, 1),
                                    ),
                                    child: TextButton(
                                      child: cargandoRuta
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.amber,
                                                strokeWidth: 2,
                                              ))
                                          : const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Sí, terminar',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            ),
                                      onPressed: () async {
                                        setState(() {
                                          cargandoRuta = true;
                                        });
                                        final miSalidaAParadero = await Lib()
                                            .terminarViaje(
                                                int.parse(widget.idRuta));
                                        if (miSalidaAParadero) {
                                          const storage =
                                              FlutterSecureStorage();
                                          String? value = await storage.read(
                                              key: 'SESSION');
                                          Map<String, dynamic> usuarioResponse =
                                              json.decode(value ?? '');
                                          dynamic idChofer =
                                              usuarioResponse['iIdChofer'];
                                          Random random = Random();
                                          int randomNumber =
                                              random.nextInt(10000);
                                          int randomNumbera =
                                              random.nextInt(10000);

                                          FirebaseFirestore.instance
                                              .collection('movimientos')
                                              .doc(idChofer)
                                              .set({'random': randomNumber});
                                          FirebaseFirestore.instance
                                              .collection('busquedas')
                                              .doc('cambio')
                                              .set({'random': randomNumbera});

                                          setState(() {
                                            cargandoRuta = false;
                                          });
                                          showTopSnackBar(
                                            context,
                                            const CustomSnackBar.success(
                                              message:
                                                  "Viaje completado correctamente. Vuelve pronto",
                                            ),
                                          );
                                          // Navigator.of(context).pop();
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  CupertinoPageRoute<void>(
                                                      builder: (BuildContext
                                                          context) {
                                            return const Menu();
                                          }), (Route<dynamic> route) => false);
                                        } else {
                                          showTopSnackBar(
                                            context,
                                            const CustomSnackBar.error(
                                              message:
                                                  "Lo sentimos, hubo un error, inténtalo nuevamente",
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          });
                    },
                    elevation: 0,
                    splashColor: const Color.fromRGBO(31, 31, 31, 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 0,
                        ),
                        Text('Terminar ruta',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class opcionesEnParadero extends StatefulWidget {
  const opcionesEnParadero({
    Key? key,
    required this.idRuta,
    required this.nombre,
  }) : super(key: key);
  final String idRuta;
  final String nombre;

  @override
  State<opcionesEnParadero> createState() => _opcionesEnParaderoState();
}

class _opcionesEnParaderoState extends State<opcionesEnParadero> {
  bool cargandoRuta = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      left: 10,
      right: 10,
      bottom: 110,
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
                  color: const Color.fromRGBO(31, 31, 31, 1),
                  child: MaterialButton(
                    height: 60,
                    onPressed: () {
                      showDialog<void>(
                          context: context, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                'Salir de paradero',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: const <Widget>[
                                    Text(
                                      'Tu viaje está en paradero donde tus pasajeros pueden ofertarte. ¿Quieres salir del paradero y comenzar el viaje?',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromARGB(128, 21, 21, 21)),
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
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 28, 28, 28)),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          const Color.fromRGBO(21, 21, 21, 1),
                                    ),
                                    child: TextButton(
                                      child: cargandoRuta
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.amber,
                                                strokeWidth: 2,
                                              ))
                                          : const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Sí, comenzar',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            ),
                                      onPressed: () async {
                                        setState(() {
                                          cargandoRuta = true;
                                        });
                                        final miSalidaAParadero = await Lib()
                                            .salirDeParaderoViaje(
                                                int.parse(widget.idRuta));
                                        if (miSalidaAParadero) {
                                          const storage =
                                              FlutterSecureStorage();
                                          String? value = await storage.read(
                                              key: 'SESSION');
                                          Map<String, dynamic> usuarioResponse =
                                              json.decode(value ?? '');
                                          dynamic idChofer =
                                              usuarioResponse['iIdChofer'];
                                          Random random = Random();
                                          int randomNumber =
                                              random.nextInt(10000);
                                          int randomNumbera =
                                              random.nextInt(10000);

                                          FirebaseFirestore.instance
                                              .collection('movimientos')
                                              .doc(idChofer)
                                              .set({'random': randomNumber});
                                          FirebaseFirestore.instance
                                              .collection('busquedas')
                                              .doc('cambio')
                                              .set({'random': randomNumbera});
                                          setState(() {
                                            cargandoRuta = false;
                                          });
                                          Navigator.of(context).pop();
                                        } else {
                                          showTopSnackBar(
                                            context,
                                            const CustomSnackBar.error(
                                              message:
                                                  "Lo sentimos, hubo un error, inténtalo nuevamente",
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          });
                    },
                    elevation: 0,
                    splashColor: const Color.fromRGBO(31, 31, 31, 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 0,
                        ),
                        Text('Salir de paradero',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class opcionesEnParaderoUsuario extends StatefulWidget {
  const opcionesEnParaderoUsuario(
      {Key? key,
      required this.idRutaM,
      required this.nombre,
      required this.salida_lat,
      required this.salida_long,
      required this.destino_lat,
      required this.destino_long,
      required this.nombreRutaController,
      required this.recogermosControlerNombre,
      required this.llegasControladorNombre,
      required this.direccionInicial,
      required this.direccionFinal,
      required this.distritoInicial,
      required this.distritoFinal,
      required this.provinciaInicial,
      required this.provinciaFinal,
      required this.regionInicial,
      required this.regionFinal,
      required this.direccionExactaInicial,
      required this.direccionExactaFinal})
      : super(key: key);
  final String idRutaM;
  final String nombre;
  final String salida_lat;
  final String salida_long;
  final String destino_lat;
  final String destino_long;
  final String nombreRutaController;
  final String recogermosControlerNombre;
  final String llegasControladorNombre;
  final String direccionInicial;
  final String direccionFinal;
  final String distritoInicial;
  final String distritoFinal;
  final String provinciaInicial;
  final String provinciaFinal;
  final String regionInicial;
  final String regionFinal;
  final String direccionExactaInicial;
  final String direccionExactaFinal;

  @override
  State<opcionesEnParaderoUsuario> createState() =>
      opcionesEnParaderoUsuarioState();
}

class opcionesEnParaderoUsuarioState extends State<opcionesEnParaderoUsuario> {
  bool cargandoRuta = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      left: 10,
      right: 10,
      bottom: 110,
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
                  color: const Color.fromRGBO(31, 31, 31, 1),
                  child: MaterialButton(
                    height: 60,
                    onPressed: () {
                      Navigator.of(context).push(CupertinoPageRoute<void>(
                          builder: (BuildContext context) {
                        return SolicitarAsiento(
                          idRuta: widget.idRutaM,
                          salida_lat: widget.salida_lat,
                          salida_long: widget.salida_long,
                          destino_lat: widget.destino_lat,
                          destino_long: widget.destino_long,
                          nombreRutaController: widget.nombreRutaController,
                          recogermosControlerNombre:
                              widget.recogermosControlerNombre,
                          llegasControladorNombre:
                              widget.llegasControladorNombre,
                          direccionInicial: widget.direccionInicial,
                          direccionFinal: widget.direccionFinal,
                          distritoInicial: widget.distritoInicial,
                          distritoFinal: widget.distritoFinal,
                          provinciaInicial: widget.provinciaInicial,
                          provinciaFinal: widget.provinciaFinal,
                          regionInicial: widget.regionInicial,
                          regionFinal: widget.regionFinal,
                          direccionExactaInicial: widget.direccionExactaInicial,
                          direccionExactaFinal: widget.direccionExactaFinal,
                        );
                      }));
                    },
                    elevation: 0,
                    splashColor: const Color.fromRGBO(31, 31, 31, 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 0,
                        ),
                        Text('Solicitar un asiento',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// class miOpcionestadoruta extends StatelessWidget {
//   const miOpcionestadoruta({
//     Key? key,
//     required this.idRuta,
//   }) : super(key: key);
//   final int idRuta;
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedPositioned(
//       duration: const Duration(milliseconds: 250),
//       curve: Curves.fastOutSlowIn,
//       left: 10,
//       right: 10,
//       bottom: 110,
//       child: Container(
//         decoration: const BoxDecoration(
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(8), topRight: Radius.circular(8)),
//           color: Color.fromRGBO(255, 255, 255, 0),
//         ),
//         // width: MediaQuery.of(context).size.width * 0.5,
//         height: 60,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Container(
//               decoration: const BoxDecoration(boxShadow: [
//                 BoxShadow(
//                     color: Color.fromARGB(20, 0, 0, 0),
//                     blurRadius: 10,
//                     spreadRadius: 1),
//               ]),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Container(
//                   color: Colors.white,
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       // crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         MaterialButton(
//                           // height: 60,
//                           onPressed: () {
//                             print(idRuta);
//                           },
//                           elevation: 0,
//                           splashColor: Colors.transparent,
//                           child: Row(
//                             children: const [
//                               Text('Dar inicio al viaje',
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                       color:
//                                           Color.fromARGB(255, 131, 131, 131))),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class MapaDisenio {
  static String miMapa = '''
[
    {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
            {
                "color": "#e9e9e9"
            },
            {
                "lightness": 17
            }
        ]
    },
    {
        "featureType": "landscape",
        "elementType": "geometry",
        "stylers": [
            {
                "color": "#f5f5f5"
            },
            {
                "lightness": 20
            }
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#ffffff"
            },
            {
                "lightness": 17
            }
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "geometry.stroke",
        "stylers": [
            {
                "color": "#ffffff"
            },
            {
                "lightness": 29
            },
            {
                "weight": 0.2
            }
        ]
    },
    {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
            {
                "color": "#ffffff"
            },
            {
                "lightness": 18
            }
        ]
    },
    {
        "featureType": "road.local",
        "elementType": "geometry",
        "stylers": [
            {
                "color": "#ffffff"
            },
            {
                "lightness": 16
            }
        ]
    },
    {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
            {
                "color": "#f5f5f5"
            },
            {
                "lightness": 21
            }
        ]
    },
    {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
            {
                "color": "#dedede"
            },
            {
                "lightness": 21
            }
        ]
    },
    {
        "elementType": "labels.text.stroke",
        "stylers": [
            {
                "visibility": "on"
            },
            {
                "color": "#ffffff"
            },
            {
                "lightness": 16
            }
        ]
    },
    {
        "elementType": "labels.text.fill",
        "stylers": [
            {
                "saturation": 36
            },
            {
                "color": "#333333"
            },
            {
                "lightness": 40
            }
        ]
    },
    {
        "elementType": "labels.icon",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "transit",
        "elementType": "geometry",
        "stylers": [
            {
                "color": "#f2f2f2"
            },
            {
                "lightness": 19
            }
        ]
    },
    {
        "featureType": "administrative",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#fefefe"
            },
            {
                "lightness": 20
            }
        ]
    },
    {
        "featureType": "administrative",
        "elementType": "geometry.stroke",
        "stylers": [
            {
                "color": "#fefefe"
            },
            {
                "lightness": 17
            },
            {
                "weight": 1.2
            }
        ]
    }
]
  ''';
}
