import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miruta/lista_de_pantalla.dart';

class RutasRecomendadas extends StatefulWidget {
  const RutasRecomendadas({Key? key}) : super(key: key);

  @override
  State<RutasRecomendadas> createState() => _RutasRecomendadasState();
}

class _RutasRecomendadasState extends State<RutasRecomendadas> {
  final Completer<GoogleMapController> _googlemapsControlador = Completer();
  late GoogleMapController _googleMapController;
  TextEditingController inicioControlador = TextEditingController();
  TextEditingController recogermosControler = TextEditingController();
  String recogermosControlerNombre = '';
  String recogermosControlerUbicacion = '';
  TextEditingController llegasControlador = TextEditingController();
  String llegasControladorNombre = '';
  String llegasControladorUbicacion = '';
  FocusNode recogermosControlerFocus = FocusNode();
  FocusNode llegasControladorFocus = FocusNode();

  TextEditingController nombreRutaController = TextEditingController();
  TextEditingController precioRutaController = TextEditingController();
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

  String fechahoraSalida = 'Fecha y hora de salida';
  String valorFechahoraSalida = '';

  String miRutaSeleccionada = '';
  dynamic misRecomendacionesBusqueda = [], misopcionesdeviaje = [];
  bool creandoViaje = false, buscandoDataRuta = true;

  FirebaseFirestore db = FirebaseFirestore.instance;

  late BitmapDescriptor inicioMarker;
  late BitmapDescriptor finMarker;
  final Set<Marker> _markers = <Marker>{};
  final Set<Polyline> _polylines = <Polyline>{};
  dynamic _camarainicial = '';

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

  void hacerRuta(List<LatLng> puntos) {
    String polulineId = 'polyline_rutaSeleccionada';
    _polylines.clear();
    _polylines.add(Polyline(
        polylineId: PolylineId(polulineId),
        width: 5,
        color: Colors.amber,
        points: puntos));
    setState(() {});
  }

  void obtenerUbicacionActual() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _camarainicial = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 14);
      buscandoDataRuta = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    obtenerUbicacionActual();
    resultadosBusquedaViajeSinActualizar();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void pintarPuntosInicioFin() async {
    dynamic miCamino = await Lib()
        .obtenerRuta('$salida_lat,$salida_long', '$destino_lat,$destino_long');
    _dirigirCamara(
      double.parse(salida_lat),
      double.parse(salida_long),
      miCamino['routes'][0]['bounds']['northeast'],
      miCamino['routes'][0]['bounds']['southwest'],
    );
    inicioMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/images/png/iconos/aU.png');

    finMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/images/png/iconos/bU.png');

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
    dynamic misRutasRecomendadas = await Lib()
        .rutasRecomendadas(salida_lat, salida_long, destino_lat, destino_long);
    print('mis rutaaaaaaaaaaaaaaaaaaaaas');
    print(misRutasRecomendadas);
    setState(() {
      misopcionesdeviaje = misRutasRecomendadas;
    });
  }

  resultadosBusquedaViajeSinActualizar() {   
    FirebaseFirestore.instance.collection("busquedas").doc('cambio').snapshots()
    .listen((event) async {
      if (salida_lat != '' &&
          salida_long != '' &&
          destino_lat != '' &&
          destino_long != '') {
        dynamic misRutasRecomendadas = await Lib().rutasRecomendadas(
            salida_lat, salida_long, destino_lat, destino_long);
        if (mounted) {
          setState(() {
            misopcionesdeviaje = misRutasRecomendadas;
          });
        }
      }
    });    
  }

 

  void pintarPuntosInicioFinRutaSeleccionada(
      salidalats, salidalongs, destinolats, destinolongs) async {
    dynamic miCamino = await Lib()
        .obtenerRuta('$salidalats,$salidalongs', '$destinolats,$destinolongs');
    _dirigirCamara(
      double.parse(salidalats),
      double.parse(salidalongs),
      miCamino['routes'][0]['bounds']['northeast'],
      miCamino['routes'][0]['bounds']['southwest'],
    );
    inicioMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/images/png/iconos/a.png');

    finMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/images/png/iconos/b.png');

    _agregaMarkador(
        inicioMarker,
        'InicioS',
        LatLng(
            miCamino['routes'][0]['legs'][0]['steps'][0]['start_location']
                ['lat'],
            miCamino['routes'][0]['legs'][0]['steps'][0]['start_location']
                ['lng']));
    _agregaMarkador(
        finMarker,
        'FinS',
        LatLng(
            miCamino['routes'][0]['legs'][0]['steps']
                    [miCamino['routes'][0]['legs'][0]['steps'].length - 1]
                ['end_location']['lat'],
            miCamino['routes'][0]['legs'][0]['steps']
                    [miCamino['routes'][0]['legs'][0]['steps'].length - 1]
                ['end_location']['lng']));
    // dynamic misRutasRecomendadas = await Lib().rutasRecomendadas(salidalats, salidalongs, destinolats, destinolongs);
    // print('mis rutaaaaaaaaaaaaaaaaaaaaas');
    // print(misRutasRecomendadas);
    // setState(() {
    //   misopcionesdeviaje = misRutasRecomendadas;
    // });
  }

  void _agregaMarkador(BitmapDescriptor icon, String idMrcador, LatLng puntos) {
    setState(() {
      _markers.add(
          Marker(markerId: MarkerId(idMrcador), position: puntos, icon: icon));
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
          140),
    );
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

  void buscadorModalLevantar() {
    StreamController<Object> streamBuscarLugar = StreamController();
    streamBuscarLugar.hasListener ? streamBuscarLugar.close() : null;
    setState(() {
      recogermosControler.text = recogermosControlerNombre;
      llegasControlador.text = llegasControladorNombre;
    });
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
              initialChildSize: 0.85,
              minChildSize: 0.85,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          onTap: () => recogermosControler.selection =
                              TextSelection(
                                  baseOffset: 0,
                                  extentOffset:
                                      recogermosControler.value.text.length),
                          controller: recogermosControler,
                          focusNode: recogermosControlerFocus,
                          onChanged: (value) =>
                              buscadorLugares(value, streamBuscarLugar),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                          keyboardType: TextInputType.streetAddress,
                          enableInteractiveSelection: true,
                          decoration: InputDecoration(
                              icon: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              // icon: Icon(Icons.my_location_rounded,color: Colors.amber,),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 223, 225, 226)),
                              ),
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1,
                                  )),
                              contentPadding: const EdgeInsets.only(
                                  top: 0, bottom: 0, left: 15, right: 15),
                              fillColor: Colors.white,
                              hintText: "Origen",
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: llegasControlador,
                          focusNode: llegasControladorFocus,
                          onChanged: (value) =>
                              buscadorLugares(value, streamBuscarLugar),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                          keyboardType: TextInputType.streetAddress,
                          enableInteractiveSelection: true,
                          decoration: InputDecoration(
                              icon: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  color: Colors.redAccent,
                                ),
                              ),
                              // icon: Icon(Icons.my_location_rounded,color: Colors.amber,),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 223, 225, 226)),
                              ),
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1,
                                  )),
                              contentPadding: const EdgeInsets.only(
                                  top: 0, bottom: 0, left: 15, right: 15),
                              fillColor: Colors.white,
                              hintText: "Destino",
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 5,
                        color: const Color.fromARGB(255, 245, 245, 245),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20, left: 20),
                        child: Column(children: [
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8)),
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Material(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        child: MaterialButton(
                                          height: 40,
                                          onPressed: () async {},
                                          elevation: 0,
                                          splashColor: Colors.transparent,
                                          child: Row(
                                            children: const [
                                              Icon(
                                                Icons.pin_drop_outlined,
                                                color: Color.fromARGB(
                                                    255, 134, 134, 134),
                                                size: 16,
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                  'Señalar la ubicación en el mapa',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color.fromARGB(
                                                          255, 134, 134, 134))),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      Container(
                        height: 5,
                        color: const Color.fromARGB(255, 245, 245, 245),
                      ),
                      SizedBox(
                        height: 500,
                        child: StreamBuilder(
                          stream: streamBuscarLugar.stream,
                          builder: (context, snapshot) {
                            misRecomendacionesBusqueda = snapshot.data ?? [];
                            print('aaaaaaaaaa');
                            print(misRecomendacionesBusqueda);
                            return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount: misRecomendacionesBusqueda.length,
                                itemBuilder: (context, i) {
                                  return ListTile(
                                    horizontalTitleGap: 12,
                                    minVerticalPadding: 0,
                                    dense: true,
                                    minLeadingWidth: 0,
                                    onTap: () async {
                                      if (recogermosControlerFocus.hasFocus) {
                                        setState(() {
                                          recogermosControler.text =
                                              misRecomendacionesBusqueda[i]
                                                      ['structured_formatting']
                                                  ['main_text'];
                                          recogermosControlerNombre =
                                              misRecomendacionesBusqueda[i]
                                                      ['structured_formatting']
                                                  ['main_text'];
                                          recogermosControlerUbicacion =
                                              misRecomendacionesBusqueda[i]
                                                      ['structured_formatting']
                                                  ['secondary_text'];
                                        });

                                        if (recogermosControler.text != '' &&
                                            llegasControlador.text != '') {
                                          Navigator.of(context).pop();
                                        }

                                        dynamic miInfo = await Lib()
                                            .obtenerInfoLugar(
                                                misRecomendacionesBusqueda[i]
                                                    ['place_id']);

                                        setState(() {
                                          direccionInicial = '';
                                          distritoInicial = '';
                                          provinciaInicial = '';
                                          regionInicial = '';
                                        });

                                        for (int i = 0;
                                            i <
                                                miInfo['address_components']
                                                    .length;
                                            i++) {
                                          if (miInfo['address_components'][i]
                                                  ['types']
                                              .contains('route')) {
                                            setState(() {
                                              direccionInicial =
                                                  miInfo['address_components']
                                                          [i]['long_name']
                                                      .toString();
                                            });
                                          } else if (miInfo[
                                                      'address_components'][i]
                                                  ['types']
                                              .contains('locality')) {
                                            setState(() {
                                              distritoInicial =
                                                  miInfo['address_components']
                                                          [i]['long_name']
                                                      .toString();
                                            });
                                          } else if (miInfo[
                                                      'address_components'][i]
                                                  ['types']
                                              .contains(
                                                  'administrative_area_level_2')) {
                                            var minome =
                                                miInfo['address_components'][i]
                                                        ['long_name']
                                                    .toString()
                                                    .replaceAll(
                                                        'Provincia de ', '');
                                            var minomc = minome.replaceAll(
                                                ' Province', '');
                                            setState(() {
                                              provinciaInicial = minomc;
                                            });
                                          } else if (miInfo[
                                                      'address_components'][i]
                                                  ['types']
                                              .contains(
                                                  'administrative_area_level_1')) {
                                            var minom =
                                                miInfo['address_components'][i]
                                                        ['long_name']
                                                    .toString()
                                                    .replaceAll(
                                                        'Provincia de ', '');
                                            var minomd = minom.replaceAll(
                                                'Gobierno Regional de ', '');
                                            var minomc = minomd.replaceAll(
                                                ' Province', '');
                                            var minome = minomc.replaceAll(
                                                ' Region', '');
                                            var minomf = minome.replaceAll(
                                                'Constitutional of ', '');
                                            setState(() {
                                              regionInicial = minomf;
                                            });
                                          }
                                        }

                                        setState(() {
                                          direccionExactaInicial =
                                              miInfo['formatted_address'] ??
                                                  miInfo['name'] ??
                                                  'Nombre desconocido';
                                          salida_lat = miInfo['geometry']
                                                  ['location']['lat']
                                              .toString();
                                          salida_long = miInfo['geometry']
                                                  ['location']['lng']
                                              .toString();
                                        });

                                        if (salida_lat != '' &&
                                            salida_long != '' &&
                                            destino_lat != '' &&
                                            destino_long != '') {
                                          pintarPuntosInicioFin();
                                        }
                                      } else {
                                        setState(() {
                                          llegasControlador.text =
                                              misRecomendacionesBusqueda[i]
                                                      ['structured_formatting']
                                                  ['main_text'];
                                          llegasControladorNombre =
                                              misRecomendacionesBusqueda[i]
                                                      ['structured_formatting']
                                                  ['main_text'];
                                          llegasControladorUbicacion =
                                              misRecomendacionesBusqueda[i]
                                                      ['structured_formatting']
                                                  ['secondary_text'];
                                        });
                                        if (recogermosControler.text != '' &&
                                            llegasControlador.text != '') {
                                          Navigator.of(context).pop();
                                        }
                                        dynamic miInfo = await Lib()
                                            .obtenerInfoLugar(
                                                misRecomendacionesBusqueda[i]
                                                    ['place_id']);

                                        setState(() {
                                          direccionFinal = '';
                                          distritoFinal = '';
                                          provinciaFinal = '';
                                          regionFinal = '';
                                        });

                                        for (int i = 0;
                                            i <
                                                miInfo['address_components']
                                                    .length;
                                            i++) {
                                          if (miInfo['address_components'][i]
                                                  ['types']
                                              .contains('route')) {
                                            setState(() {
                                              direccionFinal =
                                                  miInfo['address_components']
                                                          [i]['long_name']
                                                      .toString();
                                            });
                                          } else if (miInfo[
                                                      'address_components'][i]
                                                  ['types']
                                              .contains('locality')) {
                                            setState(() {
                                              distritoFinal =
                                                  miInfo['address_components']
                                                          [i]['long_name']
                                                      .toString();
                                            });
                                          } else if (miInfo[
                                                      'address_components'][i]
                                                  ['types']
                                              .contains(
                                                  'administrative_area_level_2')) {
                                            var minome =
                                                miInfo['address_components'][i]
                                                        ['long_name']
                                                    .toString()
                                                    .replaceAll(
                                                        'Provincia de ', '');
                                            var minomc = minome.replaceAll(
                                                ' Province', '');
                                            setState(() {
                                              provinciaFinal = minomc;
                                            });
                                          } else if (miInfo[
                                                      'address_components'][i]
                                                  ['types']
                                              .contains(
                                                  'administrative_area_level_1')) {
                                            var minom =
                                                miInfo['address_components'][i]
                                                        ['long_name']
                                                    .toString()
                                                    .replaceAll(
                                                        'Provincia de ', '');
                                            var minomd = minom.replaceAll(
                                                'Gobierno Regional de ', '');
                                            var minomc = minomd.replaceAll(
                                                ' Province', '');
                                            var minome = minomc.replaceAll(
                                                ' Region', '');
                                            var minomf = minome.replaceAll(
                                                'Constitutional of ', '');
                                            setState(() {
                                              regionFinal = minomf;
                                            });
                                          }
                                        }

                                        setState(() {
                                          direccionExactaFinal =
                                              miInfo['formatted_address'] ??
                                                  miInfo['name'] ??
                                                  'Nombre desconocido';
                                          destino_lat = miInfo['geometry']
                                                  ['location']['lat']
                                              .toString();
                                          destino_long = miInfo['geometry']
                                                  ['location']['lng']
                                              .toString();
                                        });

                                        if (salida_lat != '' &&
                                            salida_long != '' &&
                                            destino_lat != '' &&
                                            destino_long != '') {
                                          pintarPuntosInicioFin();
                                        }
                                      }
                                    },
                                    title: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Text(
                                        misRecomendacionesBusqueda[i]
                                                ['structured_formatting']
                                            ['main_text'],
                                        style: const TextStyle(
                                            color:
                                                Color.fromRGBO(21, 21, 21, 1),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        color: Colors.grey,
                                        child: const Icon(
                                          Icons.location_on_sharp,
                                          size: 16,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                      ),
                                    ),
                                    subtitle: Text(
                                      misRecomendacionesBusqueda[i]
                                              ['structured_formatting']
                                          ['secondary_text'],
                                      style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 63, 63, 63),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  );
                                });
                          },
                        ),
                      )
                    ]),
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: false,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
            title: const Text(
              'Buscar un viaje',
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
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.grey,
          child: Column(
            children: [
              Container(
                height: 350,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Stack(
                  children: [
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
                            myLocationEnabled: true,
                            zoomControlsEnabled: false,
                            onTap: (position) {},
                            // onCameraMove: (CameraPosition position) {
                            //   streamLatitud.add(position.target.latitude);
                            //   streamLogintud.add(position.target.longitude);
                            // },
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () => buscadorModalLevantar(),
                        child: Container(
                          height: 83,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color.fromARGB(54, 34, 34, 34)),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  minVerticalPadding: 0,
                                  visualDensity: VisualDensity.compact,
                                  horizontalTitleGap: 4,
                                  dense: true,
                                  title: Text(
                                      'Origen: $recogermosControlerNombre',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false),
                                  leading: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 15, top: 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                    height: 1,
                                    color:
                                        const Color.fromARGB(54, 34, 34, 34)),
                                ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  minVerticalPadding: 0,
                                  visualDensity: VisualDensity.compact,
                                  horizontalTitleGap: 4,
                                  dense: true,
                                  title: Text(
                                      'Destino: $llegasControladorNombre',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: false),
                                  leading: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 15, top: 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 30,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      right: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          color: miRutaSeleccionada == ''
                              ? const Color.fromARGB(255, 221, 221, 221)
                              : const Color.fromRGBO(31, 31, 31, 1),
                          child: MaterialButton(
                            height: 20,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              miRutaSeleccionada == ''
                                  ? ''
                                  : Navigator.of(context).push(
                                      CupertinoPageRoute<void>(
                                          builder: (BuildContext context) {
                                      return VerMapa(
                                          idRuta: miRutaSeleccionada,
                                          origen: 'PASAJERO',
                                          viajeEnCurso:false,
                                          salida_lat: salida_lat,
                                          salida_long: salida_long,
                                          destino_lat: destino_lat,
                                          destino_long: destino_long,
                                          nombreRutaController:
                                              nombreRutaController.text,
                                          recogermosControlerNombre:
                                              recogermosControlerNombre,
                                          llegasControladorNombre:
                                              llegasControladorNombre,
                                          direccionInicial: direccionInicial,
                                          direccionFinal: direccionFinal,
                                          distritoInicial: distritoInicial,
                                          distritoFinal: distritoFinal,
                                          provinciaInicial: provinciaInicial,
                                          provinciaFinal: provinciaFinal,
                                          regionInicial: regionInicial,
                                          regionFinal: regionFinal,
                                          direccionExactaInicial:
                                              direccionExactaInicial,
                                          direccionExactaFinal:
                                              direccionExactaFinal);
                                    }));
                            },
                            elevation: 0,
                            splashColor: const Color.fromARGB(0, 31, 31, 31),
                            child: Row(
                              children: [
                                Text('Ver detalles',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: miRutaSeleccionada == ''
                                            ? const Color.fromARGB(
                                                133, 94, 94, 94)
                                            : Colors.amber)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: misopcionesdeviaje.length,
                            itemBuilder: (context, index) {
                              return misopcionesdeviaje.length == 0
                                  ? const Center(child: Text('Sin resultdos'))
                                  : ListTile(
                                      onTap: () async {
                                        setState(() {
                                          miRutaSeleccionada =
                                              misopcionesdeviaje[index]['Id'];
                                        });
                                        dynamic miRutaPintar = await Lib()
                                            .rutasRecomendadasPosicion(
                                                misopcionesdeviaje[index]
                                                    ['Id']);
                                        print('pintaa');
                                        List<LatLng> misPuntos = [];
                                        for (int i = 0;
                                            i < miRutaPintar.length;
                                            i++) {
                                          misPuntos.add(LatLng(
                                              double.parse(
                                                  miRutaPintar[i]['latitude']),
                                              double.parse(miRutaPintar[i]
                                                  ['longitude'])));
                                        }
                                        // miRutaPintar
                                        pintarPuntosInicioFinRutaSeleccionada(
                                            miRutaPintar[0]['latitude'],
                                            miRutaPintar[0]['longitude'],
                                            miRutaPintar[miRutaPintar.length -
                                                1]['latitude'],
                                            miRutaPintar[miRutaPintar.length -
                                                1]['longitude']);
                                        hacerRuta(misPuntos);
                                      },
                                      leading: Image.asset(
                                        'assets/images/png/marca/uno.png',
                                        scale: 2.8,
                                        color:
                                            const Color.fromRGBO(31, 31, 31, 1),
                                      ),
                                      dense: true,
                                      title: Text(
                                        '${misopcionesdeviaje[index]['name']}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      subtitle: Text(
                                        '${misopcionesdeviaje[index]['vchProvinciaInicial']} - ${misopcionesdeviaje[index]['vchProvinciaFinal']}',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blueGrey
                                                .withOpacity(0.5)),
                                      ),
                                      trailing: Text(
                                        '${misopcionesdeviaje[index]['asientosOcupados']}/${misopcionesdeviaje[index]['cantidadDisponible']}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    );
                            }),
                      ))),
            ],
          ),
        ),
      ),
    );
  }
}
