import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miruta/lista_de_pantalla.dart';

class SolicitarAsiento extends StatefulWidget {
  final String idRuta;
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

  const SolicitarAsiento(
      {Key? key,
      required this.idRuta,
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
  State<SolicitarAsiento> createState() => _SolicitarAsientoState();
}

class _SolicitarAsientoState extends State<SolicitarAsiento> {
  TextEditingController precioRutaController = TextEditingController();
  TextEditingController recogermosControler = TextEditingController();
  TextEditingController llegasControlador = TextEditingController();
  FocusNode recogermosControlerFocus = FocusNode();
  FocusNode llegasControladorFocus = FocusNode();

  TextEditingController inicioControlador = TextEditingController();
  String recogermosControlerNombre = '';
  String recogermosControlerUbicacion = '';
  String llegasControladorNombre = '';
  String llegasControladorUbicacion = '';

  TextEditingController nombreRutaController = TextEditingController();
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

  dynamic misRecomendacionesBusqueda = [];
  bool creandoViaje = false, enviandoOferta= false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      salida_lat = widget.salida_lat;
      salida_long = widget.salida_long;
      destino_lat = widget.destino_lat;
      destino_long = widget.destino_long;
      recogermosControlerNombre = widget.recogermosControlerNombre;
      llegasControladorNombre = widget.llegasControladorNombre;
      direccionInicial = widget.direccionInicial;
      direccionFinal = widget.direccionFinal;
      distritoInicial = widget.distritoInicial;
      distritoFinal = widget.distritoFinal;
      provinciaInicial = widget.provinciaInicial;
      provinciaFinal = widget.provinciaFinal;
      regionInicial = widget.regionInicial;
      regionFinal = widget.regionFinal;
      direccionExactaInicial = widget.direccionExactaInicial;
      direccionExactaFinal = widget.direccionExactaFinal;
    });
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
                              icon: Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    width: 15,
                                    height: 15,
                                    color: Colors.greenAccent,
                                  ),
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
                              hintText: "¿Dónde inicias tu viaje?",
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
                              icon: Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    width: 15,
                                    height: 15,
                                    color: Colors.redAccent,
                                  ),
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
                              hintText: "¿A dónde quieres ir?",
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
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
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
                                            setState(() {
                                              regionInicial = minome;
                                            });
                                          }
                                        }

                                        setState(() {
                                          direccionExactaInicial =
                                              miInfo['formatted_address'] ??
                                                  miInfo['name'] ??
                                                  '';

                                          salida_lat = miInfo['geometry']
                                                  ['location']['lat']
                                              .toString();
                                          salida_long = miInfo['geometry']
                                                  ['location']['lng']
                                              .toString();
                                        });
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
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
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
                                            setState(() {
                                              regionFinal = minome;
                                            });
                                          }
                                        }

                                        setState(() {
                                          direccionExactaFinal =
                                              miInfo['formatted_address'] ??
                                                  miInfo['name'] ??
                                                  '';

                                          destino_lat = miInfo['geometry']
                                                  ['location']['lat']
                                              .toString();
                                          destino_long = miInfo['geometry']
                                                  ['location']['lng']
                                              .toString();
                                        });
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
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
          title: const Text(
            'Solicitar un asiento',
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8), topLeft: Radius.circular(8)),
              child: Container(
                color: const Color.fromRGBO(34, 34, 34, 1),
                child: const Padding(
                  padding:
                      EdgeInsets.only(top: 6, right: 10, bottom: 5, left: 10),
                  child: Text('Embarque y desembarque',
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => buscadorModalLevantar(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  border:
                      Border.all(color: const Color.fromRGBO(34, 34, 34, 1)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        minVerticalPadding: 1,
                        visualDensity: VisualDensity.compact,
                        horizontalTitleGap: 0,
                        dense: true,
                        title: Text(recogermosControlerNombre,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false),
                        subtitle: Text(direccionExactaInicial,
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false),
                        leading: Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              width: 15,
                              height: 15,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                        trailing: const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Text('Cambiar',style: TextStyle(color: Colors.black,fontSize: 10,fontWeight: FontWeight.bold),),
                        ),
                      ),
                      Container(
                          height: 1,
                          color: const Color.fromRGBO(34, 34, 34, 1)),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        minVerticalPadding: 1,
                        visualDensity: VisualDensity.compact,
                        horizontalTitleGap: 0,
                        dense: true,
                        title: Text(llegasControladorNombre,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false),
                        subtitle: Text(direccionExactaFinal,
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false),
                        trailing: const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Text('Cambiar',style: TextStyle(color: Colors.black,fontSize: 10,fontWeight: FontWeight.bold),),
                        ),
                        leading: Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              width: 15,
                              height: 15,
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
            // const SizedBox(
            //   height: 20,
            // ),
            // const Text(
            //   'Ingresa el monto que quieres pagar por el viaje que vas a realizar. El Conductor lo verificará y te notificará si lo acepta o te realiza una contra oferta.',
            //   style: TextStyle(
            //       color: Colors.black87,
            //       fontWeight: FontWeight.w500,
            //       fontSize: 10),
            // ),
            const SizedBox(
              height: 20,
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8), topLeft: Radius.circular(8)),
              child: Container(
                color: const Color.fromRGBO(34, 34, 34, 1),
                child: const Padding(
                  padding:
                      EdgeInsets.only(top: 6, right: 10, bottom: 5, left: 10),
                  child: Text('Ofrecer un precio',
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            Container(
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
                controller: precioRutaController,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                    fillColor: Colors.white,
                    hintText: "Precio del pasaje en soles",
                    hintStyle: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: const Color.fromRGBO(31, 31, 31, 1),
                child: MaterialButton(
                  height: 60,
                  onPressed: () async {
                    const storage = FlutterSecureStorage();
                    final session = Session();

                    if (salida_lat == '' ||
                        salida_long == '' ||
                        destino_lat == '' ||
                        destino_long == '') {
                      showTopSnackBar(
                        context,
                        const CustomSnackBar.info(
                          message:
                              "Debes elegir un punto de embarque y desembarque.",
                        ),
                      );
                    } else if (precioRutaController.text == '') {
                      showTopSnackBar(
                        context,
                        const CustomSnackBar.info(
                          message: "Debes ofertar un monto por el asiento.",
                        ),
                      );
                    } else {
                      setState(() {
                          enviandoOferta = true;
                        });
                      String? value = await storage.read(key: 'SESSION');
                      Map<String, dynamic> usuarioResponse =
                          json.decode(value ?? '');
                      print('llllllllllllllll');
                      print(usuarioResponse);

                      String miRes = await Lib().validarSolicitud(usuarioResponse['id'],widget.idRuta); 
                      // E  -  error
                      // N  -  no hay mas asientos / asientos ocupados
                      // A  -  ya se ha enviado solicitudes
                      // B  -  si se puede enviar ( esperado )
                      switch(miRes){
                        case 'B':
                              bool res = await Lib().crearSolicitudesxidRuta(usuarioResponse['id'],widget.idRuta,precioRutaController.text,salida_lat,salida_long,destino_lat,destino_long,recogermosControlerNombre,llegasControladorNombre,direccionInicial,direccionFinal,distritoInicial,distritoFinal,provinciaInicial,provinciaFinal,regionInicial,regionFinal,direccionExactaInicial,direccionExactaFinal);
                              Random random = Random();
                                          int randomNumber =
                                              random.nextInt(10000);

                                          FirebaseFirestore.instance
                                              .collection('solicitudes')
                                              .doc(widget.idRuta)
                                              .set({'random': randomNumber});
                              if (res) {
                                setState(() {
                                  enviandoOferta = false;
                                });
                                showTopSnackBar(
                                  context,
                                  const CustomSnackBar.success(textStyle: TextStyle(fontSize: 12,color: Colors.white),
                                    message:
                                        "Oferta enviada correctamente. Espera la respuesta de conductor.",
                                  ),
                                );
                                Navigator.pop(context);
                              } else {
                                setState(() {
                                  enviandoOferta = false;
                                });
                                showTopSnackBar(
                                  context,
                                  const CustomSnackBar.error(textStyle: TextStyle(fontSize: 12,color: Colors.white),
                                    message:
                                        "Error del servidor. Inténtalo nuevamente.",
                                  ),
                                );
                              }
                            break;
                        case 'E':
                                setState(() {
                                  enviandoOferta = false;
                                });
                              showTopSnackBar(
                                  context,
                                  const CustomSnackBar.error(textStyle: TextStyle(fontSize: 12,color: Colors.white),
                                    message:
                                        "Error del servidor. Inténtalo nuevamente.",
                                  ),
                                );
                          break;
                        case 'N':
                              showTopSnackBar(
                                  context,
                                  const CustomSnackBar.info(textStyle: TextStyle(fontSize: 12,color: Colors.white),
                                    message:
                                        "Lamentamos informarle que ya no hay asientos disponibles para este viaje.",
                                  ),
                                );
                                Navigator.pop(context);
                          break;
                        case 'A':
                              showTopSnackBar(
                                  context,
                                  const CustomSnackBar.info(textStyle: TextStyle(fontSize: 12,color: Colors.white),
                                    message:
                                        "Ya enviaste una solicitud a este viaje. Espera una respuesta del conductor en tu bandeja de notificaciones.",
                                  ),
                                );
                                Navigator.pop(context);
                          break;

                      }

                    }
                    // Navigator.of(context).push(CupertinoPageRoute<void>(
                    //     builder: (BuildContext context) {
                    //   return GestionEstadoRuta(
                    //       nombreViaje: nombre,
                    //       distancia: distancia,
                    //       tiempo: tiempo,
                    //       precio: precio,
                    //       idRuta: idRuta);
                    // }));
                  },
                  elevation: 0,
                  splashColor: const Color.fromRGBO(31, 31, 31, 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      const SizedBox(
                        height: 0,
                      ),
                      enviandoOferta
                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.amber,
                                      strokeWidth: 2,
                                    ))
                      : const Text('Enviar oferta',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.amber)),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
