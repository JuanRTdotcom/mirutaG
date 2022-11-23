import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miruta/lista_de_pantalla.dart';

class VerSolicitudViaje extends StatefulWidget {
  final String idRuta;
  final String origen;
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

  const VerSolicitudViaje({Key? key, required this.idRuta, required this.origen, required this.salida_lat, required this.salida_long, required this.destino_lat, required this.destino_long, required this.nombreRutaController, required this.recogermosControlerNombre, required this.llegasControladorNombre, required this.direccionInicial, required this.direccionFinal, required this.distritoInicial, required this.distritoFinal, required this.provinciaInicial, required this.provinciaFinal, required this.regionInicial, required this.regionFinal, required this.direccionExactaInicial, required this.direccionExactaFinal}) : super(key: key);


  @override
  State<VerSolicitudViaje> createState() => _VerSolicitudViajeState();
}

class _VerSolicitudViajeState extends State<VerSolicitudViaje> {
  late GoogleMapController _googleMapController;
  final Completer<GoogleMapController> _googlemapsControlador = Completer();
  final Set<Polyline> _polylines = <Polyline>{};
  final Set<Marker> _markers = <Marker>{};
  bool buscandoDataRuta = false, rutaConAsientos = false;

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

  Future<void> _dirigirCamara(double latInicial, double longInicial,
      Map<String, dynamic> vistaNorte, Map<String, dynamic> vistaSur) async {
    final GoogleMapController controller = await _googlemapsControlador.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(latInicial, latInicial), zoom: 12)),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: LatLng(vistaSur['lat'], vistaSur['lng']),
              northeast: LatLng(vistaNorte['lat'], vistaNorte['lng'])),
          140),
    );
  }

  Future<void> listarInfoRuta() async {
    setState(() {
      buscandoDataRuta = true;
    });

    dynamic res = await Lib().listarRutaid(widget.idRuta);
    print('pppppppppppppppppppppppppppppppppppppppppp');
    print(res);
    dynamic miCamino = await Lib().obtenerRuta(
        '${res[0]['vchLatInicial']},${res[0]['vchLongInicial']}',
        '${res[0]['vchLatFinal']},${res[0]['vchLongFinal']}');

    setState(() {
      idConductor = res[0]['iIdVehiculo'];
    });
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
      estadoRuta = res[0]['EstadoServicio'].trim();
      asientosTotales = res[0]['asientos'];
      asientosOcupados = res[0]['asientosOcupados'];

      if (estadoRuta == 'EN_PARADERO' ||
          estadoRuta == 'EN_RUTA' ||
          estadoRuta == 'FINALIZADO') {
        setState(() {
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
        case 'NO_DISPONIBLE':
          setState(() {
            nombreEstadoRuta = 'Viaje no disponible';
          });
          break;
        default:
          break;
      }
      // miLatitud =
      // miLatitud = res
    });
  }

  void _agregaMarkador(BitmapDescriptor icon, String idMrcador, LatLng puntos) {
    setState(() {
      _markers.add(
          Marker(markerId: MarkerId(idMrcador), position: puntos, icon: icon));
    });
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
      case 'NO_DISPONIBLE':
        return opcionesCrearNuevaRuta(
            idRuta: miidRuta,
            nombre: nombreViaje,
            distancia: distancia,
            precio: precio,
            tiempo: tiempo);
      default:
        return const SizedBox(
          width: 0,
        );
    }
  }
  
  Widget verbotonOpcionesPasajero(estadoRuta, miidRuta) {
    switch (estadoRuta.trim()) {
      case 'CREADO':
        return const SizedBox(width: 0,);
      case 'EN_PARADERO':
        return opcionesEnParaderoUsuario(idRutaM: miidRuta, nombre: nombreViaje,salida_lat: widget.salida_lat,salida_long: widget.salida_long,destino_lat: widget.destino_lat,destino_long: widget.destino_long,
                                                nombreRutaController : widget.nombreRutaController,
                                                recogermosControlerNombre : widget.recogermosControlerNombre,
                                                llegasControladorNombre : widget.llegasControladorNombre,
                                                direccionInicial : widget.direccionInicial,
                                                direccionFinal : widget.direccionFinal,
                                                distritoInicial : widget.distritoInicial,
                                                distritoFinal : widget.distritoFinal,
                                                provinciaInicial : widget.provinciaInicial,
                                                provinciaFinal : widget.provinciaFinal,
                                                regionInicial : widget.regionInicial,
                                                regionFinal : widget.regionFinal,
                                                direccionExactaInicial : widget.direccionExactaInicial,
                                                direccionExactaFinal : widget.direccionExactaFinal);
      case 'EN_RUTA':
        return opcionesEnParaderoUsuario(idRutaM: miidRuta, nombre: nombreViaje,salida_lat: widget.salida_lat,salida_long: widget.salida_long,destino_lat: widget.destino_lat,destino_long: widget.destino_long,
                                                nombreRutaController : widget.nombreRutaController,
                                                recogermosControlerNombre : widget.recogermosControlerNombre,
                                                llegasControladorNombre : widget.llegasControladorNombre,
                                                direccionInicial : widget.direccionInicial,
                                                direccionFinal : widget.direccionFinal,
                                                distritoInicial : widget.distritoInicial,
                                                distritoFinal : widget.distritoFinal,
                                                provinciaInicial : widget.provinciaInicial,
                                                provinciaFinal : widget.provinciaFinal,
                                                regionInicial : widget.regionInicial,
                                                regionFinal : widget.regionFinal,
                                                direccionExactaInicial : widget.direccionExactaInicial,
                                                direccionExactaFinal : widget.direccionExactaFinal);
      case 'FINALIZADO':
        return const SizedBox(width: 0,);
      case 'NO_DISPONIBLE':
        return const SizedBox(width: 0,);
      default:
        return const SizedBox(
          width: 0,
        );
    }
  }

  @override
  void initState() {
    super.initState();
    listarInfoRuta();
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
            ? TextButton(
              onPressed: () {
                Navigator.of(context).push(
                    CupertinoPageRoute<void>(builder: (BuildContext context) {
                  return SolicitudDeAsiento(idRuta: widget.idRuta,origen: widget.origen,);
                }));
              },
              child: const Icon(
                Icons.email_outlined,
                color: Colors.amber,
              ),
            )
            : const SizedBox(height: 0,),
            widget.origen == 'PASAJERO'
            ? idConductor == ''
              ? const Text('-')
              : TextButton(
              onPressed: () {
                Navigator.of(context).push(
                    CupertinoPageRoute<void>(builder: (BuildContext context) {
                  return InformacionConductor(idConductor: idConductor);
                }));
              },
              child: const Icon(
                Icons.badge_outlined,
                color: Colors.amber,
              ),
            )
            : const SizedBox(height: 0,),
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
                    ? verbotonOpcionestadoRuta(estadoRuta, widget.idRuta)
                    : const SizedBox(
                        width: 0,
                      ),
                widget.origen == 'PASAJERO'
                    ? verbotonOpcionesPasajero(estadoRuta, widget.idRuta)
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
                                                  : 'Precio',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Clan'),
                                            ),
                                            Text(
                                              rutaConAsientos
                                                  ? '$asientosOcupados / $asientosTotales'
                                                  : 'S/. $precio',
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
