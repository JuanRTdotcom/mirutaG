import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miruta/lista_de_pantalla.dart';

class GestiosMisRutas extends StatefulWidget {
  const GestiosMisRutas({Key? key}) : super(key: key);

  @override
  State<GestiosMisRutas> createState() => _GestiosMisRutasState();
}

class _GestiosMisRutasState extends State<GestiosMisRutas> {
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

  dynamic misRecomendacionesBusqueda = [];
  bool creandoViaje = false;

  FirebaseFirestore db = FirebaseFirestore.instance;

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

  @override
  void dispose() {
    super.dispose();
  }

String convertirHora(String fecha){
  List misMeses = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];

  String miAnio = fecha.substring(0,4);
  String miMes = misMeses[int.parse(fecha.substring(5,7))-1];
  String midia = fecha.substring(8,10);
  String miHoras = fecha.substring(11,13);
  String miMinutos = fecha.substring(14,16);
  if(int.parse(miHoras)>=12){
    var acc = '';
    var miAc = int.parse(miHoras)-12;
    
    if(miAc.toString().length == 1){
      acc = '0${miAc.toString()}';
    }else{
      acc = '$miAc';

    }
    miHoras = acc+':'+ miMinutos +' p.m';
    if(miAc == 0){
      miHoras = '00'':'+ miMinutos +' p.m';
      
    }
  }else{
    miHoras = miHoras+':'+ miMinutos +' a.m';
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
                          decoration: const InputDecoration(
                              icon: IconoPinTextodentro(textoIcono: 'A'),
                              // icon: Icon(Icons.my_location_rounded,color: Colors.amber,),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 223, 225, 226)),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1,
                                  )),
                              contentPadding: EdgeInsets.only(
                                  top: 0, bottom: 0, left: 15, right: 15),
                              fillColor: Colors.white,
                              hintText: "¿Dónde inicias tu viaje?",
                              hintStyle: TextStyle(
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
                          decoration: const InputDecoration(
                              icon: IconoPinTextodentro(textoIcono: 'B'),
                              // icon: Icon(Icons.my_location_rounded,color: Colors.amber,),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 223, 225, 226)),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1,
                                  )),
                              contentPadding: EdgeInsets.only(
                                  top: 0, bottom: 0, left: 15, right: 15),
                              fillColor: Colors.white,
                              hintText: "¿A dónde quieres ir?",
                              hintStyle: TextStyle(
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
            elevation: 0,
            title: const Text(''),
            centerTitle: true,
            leading: Builder(builder: (context) {
              return IconButton(
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
              );
            })),
        body: Container(
          color: Colors.amber,
          child: Column(
            children: [
              Container(
                height: 180,
                width: MediaQuery.of(context).size.width,
                color: Colors.amber,
                child: Stack(
                  children: [
                    const Positioned(
                      top: 80,
                      left: 15,
                      child: Text(
                        'Creando un viaje',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 21, 21, 21),
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                    Positioned(
                      top: 110,
                      left: 15,
                      right: MediaQuery.of(context).size.width * 0.3,
                      child: const Text(
                        'Completa el siguiente formulario, así podrán visualizarte tus próximos pasajeros.',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color.fromARGB(140, 21, 21, 21),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Positioned(
                      right: -20,
                      bottom: 5,
                      child: Image.asset(
                        'assets/images/png/default/camion.png',
                        scale: 1,
                        width: MediaQuery.of(context).size.width * 0.40,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30, left: 30),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  topLeft: Radius.circular(8)),
                              child: Container(
                                color: const Color.fromRGBO(34, 34, 34, 1),
                                child: const Padding(
                                  padding: EdgeInsets.only(
                                      top: 6, right: 10, bottom: 5, left: 10),
                                  child: Text('Nombre del viaje',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
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
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(0),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              child: TextField(
                                controller: nombreRutaController,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                                keyboardType: TextInputType.name,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(15),
                                    fillColor: Colors.white,
                                    hintText: "Nombre del nuevo viaje",
                                    hintStyle: TextStyle(color: Colors.grey)),
                              ),
                            ),
                            // const SizedBox(
                            //   height: 20,
                            // ),
                            // ClipRRect(
                            //   borderRadius: const BorderRadius.only(
                            //       topRight: Radius.circular(8),
                            //       topLeft: Radius.circular(8)),
                            //   child: Container(
                            //     color: const Color.fromRGBO(34, 34, 34, 1),
                            //     child: const Padding(
                            //       padding: EdgeInsets.only(
                            //           top: 6, right: 10, bottom: 5, left: 10),
                            //       child: Text('Precio en soles',
                            //           style: TextStyle(
                            //               color: Color.fromARGB(
                            //                   255, 255, 255, 255),
                            //               fontSize: 12,
                            //               fontWeight: FontWeight.w600)),
                            //     ),
                            //   ),
                            // ),
                            // Container(
                            //   height: 50,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     border: Border.all(
                            //       color: const Color.fromRGBO(34, 34, 34, 1),
                            //       width: 1,
                            //     ),
                            //     borderRadius: const BorderRadius.only(
                            //         topRight: Radius.circular(10),
                            //         topLeft: Radius.circular(0),
                            //         bottomLeft: Radius.circular(10),
                            //         bottomRight: Radius.circular(10)),
                            //   ),
                            //   child: TextField(
                            //     controller: precioRutaController,
                            //     style: const TextStyle(
                            //         fontSize: 12, fontWeight: FontWeight.w600),
                            //     keyboardType: TextInputType.number,
                            //     decoration: const InputDecoration(
                            //         border: InputBorder.none,
                            //         contentPadding: EdgeInsets.all(15),
                            //         fillColor: Colors.white,
                            //         hintText: "Precio del pasaje",
                            //         hintStyle: TextStyle(color: Colors.grey)),
                            //   ),
                            // ),
                            // const SizedBox(
                            //   height: 20,
                            // ),
                            // ClipRRect(
                            //   borderRadius: const BorderRadius.only(
                            //       topRight: Radius.circular(8),
                            //       topLeft: Radius.circular(8)),
                            //   child: Container(
                            //     color: const Color.fromRGBO(34, 34, 34, 1),
                            //     child: const Padding(
                            //       padding: EdgeInsets.only(
                            //           top: 6, right: 10, bottom: 5, left: 10),
                            //       child: Text('Nro de asientos',
                            //           style: TextStyle(
                            //               color: Color.fromARGB(
                            //                   255, 255, 255, 255),
                            //               fontSize: 12,
                            //               fontWeight: FontWeight.w600)),
                            //     ),
                            //   ),
                            // ),
                            // Container(
                            //   height: 50,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     border: Border.all(
                            //       color: const Color.fromRGBO(34, 34, 34, 1),
                            //       width: 1,
                            //     ),
                            //     borderRadius: const BorderRadius.only(
                            //         topRight: Radius.circular(10),
                            //         topLeft: Radius.circular(0),
                            //         bottomLeft: Radius.circular(10),
                            //         bottomRight: Radius.circular(10)),
                            //   ),
                            //   child: TextField(
                            //     controller: asientosRutaController,
                            //     style: const TextStyle(
                            //         fontSize: 12, fontWeight: FontWeight.w600),
                            //     keyboardType: TextInputType.number,
                            //     decoration: const InputDecoration(
                            //         border: InputBorder.none,
                            //         contentPadding: EdgeInsets.all(15),
                            //         fillColor: Colors.white,
                            //         hintText: "Cantidad de sientos habilitados",
                            //         hintStyle: TextStyle(color: Colors.grey)),
                            //   ),
                            // ),                           
                            // const SizedBox(
                            //   height: 20,
                            // ),
                            // ClipRRect(
                            //   borderRadius: const BorderRadius.only(
                            //       topRight: Radius.circular(8),
                            //       topLeft: Radius.circular(8)),
                            //   child: Container(
                            //     color: const Color.fromRGBO(34, 34, 34, 1),
                            //     child: const Padding(
                            //       padding: EdgeInsets.only(
                            //           top: 6, right: 10, bottom: 5, left: 10),
                            //       child: Text('Fecha y hora de salida',
                            //           style: TextStyle(
                            //               color: Color.fromARGB(
                            //                   255, 255, 255, 255),
                            //               fontSize: 12,
                            //               fontWeight: FontWeight.w600)),
                            //     ),
                            //   ),
                            // ),
                            // Container(
                            //   height: 50,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     border: Border.all(
                            //       color: const Color.fromRGBO(34, 34, 34, 1),
                            //       width: 1,
                            //     ),
                            //     borderRadius: const BorderRadius.only(
                            //         topRight: Radius.circular(10),
                            //         topLeft: Radius.circular(0),
                            //         bottomLeft: Radius.circular(10),
                            //         bottomRight: Radius.circular(10)),
                            //   ),
                            //   child: TextButton(
                            //     onPressed: () {
                            //       DatePicker.showDateTimePicker(context,
                            //           currentTime: DateTime.now(),
                            //           showTitleActions: true,
                            //           // minTime: DateTime(2020, 5, 5, 20, 50),
                            //           // maxTime: DateTime(2020, 6, 7, 05, 09),
                                      
                            //           // onChanged: (date) {
                            //           // print('change $date in time zone ' +
                            //           //     date.timeZoneOffset.inHours.toString());
                            //           // }, 
                            //           onConfirm: (date) {
                            //             setState(() {
                            //               valorFechahoraSalida = '$date';
                            //               fechahoraSalida = convertirHora('$date');
                            //             });
                            //             // print('confirm $date');
                            //           }, 
                            //           locale: LocaleType.es);
                            //     },
                            //     child: Row(
                            //       children: [
                            //         Padding(
                            //           padding: const EdgeInsets.only(
                            //           top: 6, right: 5, bottom: 5, left: 5),
                            //           child: valorFechahoraSalida==''
                            //           ? Text(
                            //           fechahoraSalida,
                            //           style: const TextStyle(color: Colors.grey,fontSize: 12),
                            //       )
                            //           : Text(
                            //           fechahoraSalida,
                            //           style: const TextStyle(color: Color.fromRGBO(34, 34, 34, 1),fontSize: 12),
                            //       ),
                            //         )
                            //       ],
                            //     )),
                            // ),                           
                            const SizedBox(
                              height: 20,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              // borderRadius: const BorderRadius.only(topRight: Radius.circular(8),bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8)),
                              child: Material(
                                color: const Color.fromRGBO(34, 34, 34, 1),
                                child: MaterialButton(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      side: BorderSide(
                                          color:
                                              Color.fromRGBO(34, 34, 34, 1))),
                                  height: 50,
                                  onPressed: () async =>
                                      buscadorModalLevantar(),
                                  elevation: 0,
                                  splashColor: Colors.transparent,
                                  child: Row(
                                    children: const [
                                      Expanded(
                                        child: Text('Origen - Destino',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255))),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color.fromRGBO(34, 34, 34, 1)),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 4),
                                      minVerticalPadding: 1,
                                      visualDensity: VisualDensity.compact,
                                      horizontalTitleGap: 8,
                                      dense: true,
                                      title: Text(recogermosControlerNombre,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: false),
                                      subtitle: Text(
                                          recogermosControlerUbicacion,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: false),
                                      leading: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 6, top: 4),
                                        child: Transform.scale(
                                          scale: 0.8,
                                          child: const IconoPinTextodentro(
                                              textoIcono: 'A'),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        height: 1,
                                        color: const Color.fromRGBO(
                                            34, 34, 34, 1)),
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 4),
                                      minVerticalPadding: 1,
                                      visualDensity: VisualDensity.compact,
                                      horizontalTitleGap: 8,
                                      dense: true,
                                      title: Text(llegasControladorNombre,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.fade,
                                          maxLines: 2,
                                          softWrap: false),
                                      subtitle: Text(llegasControladorUbicacion,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: false),
                                      leading: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 6, top: 4),
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
                            )
                          ],
                        ),
                      ),
                    )),
              )),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: GestureDetector(
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (nombreRutaController.text.trim() == '' ||
                            // precioRutaController.text.trim() == '' ||
                            recogermosControlerNombre == '' ||
                            llegasControladorNombre == '' 
                            // asientosRutaController.text == ''
                            ) {
                          showTopSnackBar(
                            context,
                            const CustomSnackBar.info(
                              message:
                                  "Primero necesitas completar toda la informacíón",
                            ),
                          );
                        } else if (salida_lat == '' ||
                            salida_long == '' ||
                            destino_lat == '' ||
                            destino_long == ''
                            // valorFechahoraSalida == ''
                            ) {
                          showTopSnackBar(
                            context,
                            const CustomSnackBar.error(
                              message:
                                  "Lo sentimos, hubo un error de conexión, inténtalo nuevamente",
                            ),
                          );
                          Navigator.of(context).pushReplacement(
                              CupertinoPageRoute<void>(
                                  builder: (BuildContext context) {
                            return const MisRutas();
                          }));
                        } else {
                          setState(() {
                            creandoViaje = true;
                          });
                          const storage = FlutterSecureStorage();
                          String? value = await storage.read(key: 'SESSION');
                          Map<String, dynamic> usuarioResponse =
                              json.decode(value ?? '');
                          // dynamic conServicio = await Lib().validarSaldoChofer(usuarioResponse['id']);
                          dynamic mispuntosderuta = await Lib().obtenerRuta('$salida_lat,$salida_long','$destino_lat,$destino_long');
                          
                          print('mispntos de rutaa');
                          print(mispuntosderuta);
                          List misPuntos = mispuntosderuta['routes'][0]['legs'][0]['steps'];
                          List misPuntosFiltrado = [];
                          misPuntosFiltrado = misPuntos.map((user) => user['start_location']).toList();
                          misPuntosFiltrado.add(misPuntos[misPuntos.length - 1]['end_location']);
                          // for( int i = 0 ; i > misPuntos.length; i++ ) { 
                          //    misPuntosFiltrado.add(misPuntos[i]['start_location']);
                          //    if(i == misPuntos.length -1){
                          //    misPuntosFiltrado.add(misPuntos[i]['end_location']);
                          //    }
                          // } 
                          dynamic puntosJson = jsonEncode(misPuntosFiltrado);
                          print('misRutasasdasdsadasdaaa');
                          print(puntosJson);
                          // mispuntosderuta['routes'][0]['legs'][0]['steps'][0]['start_location']

                          dynamic res = await Lib().crearRuta(
                              usuarioResponse['id'],
                              nombreRutaController.text,
                              // precioRutaController.text,
                              // asientosRutaController.text,
                              // valorFechahoraSalida,
                              salida_lat,
                              destino_lat,
                              salida_long,
                              destino_long,
                              puntosJson,
                              recogermosControlerNombre,
                              llegasControladorNombre,
                              direccionInicial,
                              direccionFinal,
                              distritoInicial,
                              distritoFinal,
                              provinciaInicial,
                              provinciaFinal,
                              regionInicial,
                              regionFinal,
                              direccionExactaInicial,
                              direccionExactaFinal);
                          if (!res) {
                            setState(() {
                              creandoViaje = false;
                            });
                            showTopSnackBar(
                              context,
                              const CustomSnackBar.error(
                                message:
                                    "Error del servidor. Inténtalo nuevamente.",
                              ),
                            );

                            Navigator.of(context).pushReplacement(
                                CupertinoPageRoute<void>(
                                    builder: (BuildContext context) {
                              return const MisRutas();
                            }));
                          } else {
                            dynamic idChofer = usuarioResponse['iIdChofer'];
                            Random random = Random();
                            int randomNumber = random.nextInt(10000);

                            await db
                                .collection('movimientos')
                                .doc(idChofer)
                                .set({'random': randomNumber});
                            setState(() {
                              creandoViaje = false;
                            });

                            Navigator.pop(context);
                            showTopSnackBar(
                              context,
                              const CustomSnackBar.success(
                                message: "Nuevo viaje creado correctamente.",
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        color: Colors.amber,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: creandoViaje
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Color.fromRGBO(21, 21, 21, 1),
                                      strokeWidth: 2,
                                    ))
                                : const Text(
                                    'Crear viaje',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 21, 21, 21),
                                        fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
