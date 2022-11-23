import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:miruta/lista_de_pantalla.dart';

class InfoPersonal extends StatefulWidget {
  final String numeroTelefono;
  final String codigo;

  const InfoPersonal(
      {Key? key, required this.numeroTelefono, required this.codigo})
      : super(key: key);

  @override
  State<InfoPersonal> createState() => _InfoPersonalState();
}

class _InfoPersonalState extends State<InfoPersonal> {
  dynamic dniController = TextEditingController();
  dynamic nombresController = TextEditingController();
  dynamic paternoController = TextEditingController();
  dynamic maternoController = TextEditingController();
  int sexo = 1;

  bool cargrRegistro = false;

  @override
  Widget build(BuildContext context) {
    final FocusScopeNode focus = FocusScope.of(context);
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Clan'),
      debugShowCheckedModeBanner: false,
      home: GestureDetector(
        onTap: () {
          if (!focus.hasPrimaryFocus && focus.hasFocus) {
            FocusManager.instance.primaryFocus!.unfocus();
          }
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: Padding(
            padding: const EdgeInsets.all(0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: 125,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          child: Image.asset(
                              'assets/images/png/login/personales.png',
                              width: 150,
                              height: 124,
                              fit: BoxFit.contain),
                        ),
                        Positioned(
                          top: 25,
                          left: 3,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                                color: Colors.white,
                                width: 50,
                                height: 50,
                                child: const Icon(
                                    Icons.arrow_back_ios_new_rounded)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Datos personales',
                      style:
                          TextStyle(fontSize: 38, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 60,
                      child: CustomSlidingSegmentedControl<int>(
                        initialValue: sexo,
                        fromMax: true,
                        children: {
                          1: SizedBox(
                            width: (MediaQuery.of(context).size.width / 2) - 56,
                            child: const Text(
                              'Masculino',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                          2: SizedBox(
                            width: (MediaQuery.of(context).size.width / 2) - 56,
                            child: const Text(
                              'Femenino',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          )
                        },
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        thumbDecoration: BoxDecoration(
                          color: const Color.fromRGBO(252, 226, 0, 1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.1),
                              blurRadius: 4.0,
                              spreadRadius: 1.0,
                              offset: const Offset(
                                0.0,
                                2.0,
                              ),
                            ),
                          ],
                        ),
                        onValueChanged: (int value) {
                          setState(() {
                            sexo = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromRGBO(192, 192, 192, 1),
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: TextFormField(
                        controller: dniController,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.numbers_rounded,
                                color: Color.fromRGBO(192, 192, 192, 1),
                                size: 24.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            fillColor: Colors.white,
                            hintText: "Doc de Identidad",
                            hintStyle: TextStyle(
                                color: Color.fromRGBO(192, 192, 192, 1))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromRGBO(192, 192, 192, 1),
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: TextFormField(
                        controller: nombresController,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_pin_circle_rounded,
                                color: Color.fromRGBO(192, 192, 192, 1),
                                size: 24.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            fillColor: Colors.white,
                            hintText: "Nombres",
                            hintStyle: TextStyle(
                                color: Color.fromRGBO(192, 192, 192, 1))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromRGBO(192, 192, 192, 1),
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: TextFormField(
                        controller: paternoController,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(
                                Icons.supervised_user_circle_rounded,
                                color: Color.fromRGBO(192, 192, 192, 1),
                                size: 24.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            fillColor: Colors.white,
                            hintText: "Primer Apellido",
                            hintStyle: TextStyle(
                                color: Color.fromRGBO(192, 192, 192, 1))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromRGBO(192, 192, 192, 1),
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: TextFormField(
                        controller: maternoController,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(
                                Icons.supervised_user_circle_outlined,
                                color: Color.fromRGBO(192, 192, 192, 1),
                                size: 24.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            fillColor: Colors.white,
                            hintText: "Segundo Apellido",
                            hintStyle: TextStyle(
                                color: Color.fromRGBO(192, 192, 192, 1))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Material(
                      color: const Color.fromRGBO(252, 226, 0, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      child: MaterialButton(
                        // color: Color.fromARGB(255, 0, 0, 0),
                        minWidth: MediaQuery.of(context).size.width,
                        height: 60,
                        onPressed: () async {
                          setState(() {
                            cargrRegistro = true;
                          });
                          FocusScope.of(context).requestFocus(FocusNode());
                          final deviceInfoPlugin = DeviceInfoPlugin();
                          final deviceInfo = await deviceInfoPlugin.deviceInfo;
                          final map = deviceInfo.toMap();

                          int dispositivo = 2;
                          String marcaDispositivo = map['model'];
                          String nombreDispositivo = '';
                          String imeiDispositivo = '';

                          if (Platform.isAndroid) {
                            dispositivo = 2;
                            nombreDispositivo = map['device'];
                            imeiDispositivo = map['androidId'];
                          } else if (Platform.isIOS) {
                            dispositivo = 1;
                            nombreDispositivo = map['name'];
                            imeiDispositivo = map['identifierForVendor'];
                          }
                          final registroExitoso = await Lib().registrarUsuario(
                              dniController.text,
                              nombresController.text,
                              paternoController.text,
                              maternoController.text,
                              '',
                              sexo.toString(),
                              '',
                              '',
                              widget.numeroTelefono.toString(),
                              '',
                              '',
                              dispositivo.toString(),
                              marcaDispositivo,
                              nombreDispositivo,
                              imeiDispositivo,
                              '', // TODO: ver token
                              widget.codigo.toString());
                          if (registroExitoso) {
                            Navigator.of(context).pushAndRemoveUntil(
                                CupertinoPageRoute<void>(
                                    builder: (BuildContext context) {
                              return const Control();
                            }), (Route<dynamic> route) => false);
                          } else {
                            showTopSnackBar(
                              context,
                              const CustomSnackBar.error(
                                message: "Ocurrió un error en el registro",
                              ),
                            );
                          }
                          setState(() {
                            cargrRegistro = false;
                          });
                        },
                        elevation: 0,
                        splashColor: Colors.transparent,
                        child: cargrRegistro
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Color.fromRGBO(21, 21, 21, 1),
                                  strokeWidth: 2,
                                ))
                            : const Text('Finalizar registro',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(21, 21, 21, 1))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
