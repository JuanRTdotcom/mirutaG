import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miruta/lista_de_pantalla.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerificacionCelular extends StatefulWidget {
  final String numeroTelefono;
  final String validationCode;

  const VerificacionCelular(
      {Key? key, required this.numeroTelefono, required this.validationCode})
      : super(key: key);

  @override
  State<VerificacionCelular> createState() => _VerificacionCelularState();
}

class _VerificacionCelularState extends State<VerificacionCelular>
    with CodeAutoFill {
  final controller = TextEditingController();
  String? otpCode;

  late Timer timer;
  bool cancelTimer = false;
  // final int _start = 60;

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code;
      if (otpCode != null) {
        controller.text = code!;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    cancel();
  }

  @override
  Widget build(BuildContext context) {
    final FocusScopeNode focus = FocusScope.of(context);
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 64,
      textStyle: const TextStyle(fontSize: 34, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 235, 241, 0.37),
        borderRadius: BorderRadius.circular(10),
      ),
    );
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: const Color.fromRGBO(21, 21, 21, 1),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verificación SMS',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Ingresa el código aquí',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 123, 123, 123)),
                ),
                const SizedBox(
                  height: 60,
                ),
                Center(
                  child:
                      Pinput(
                    length: 6,
                    controller: controller,
                    defaultPinTheme: defaultPinTheme,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                    ],
                    onCompleted: (pin) => print(pin),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Center(
                  child: Material(
                    color: const Color.fromRGBO(252, 226, 0, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: MaterialButton(
                      // color: Color.fromARGB(255, 0, 0, 0),
                      minWidth: MediaQuery.of(context).size.width - 60,
                      height: 60,
                      onPressed: () async {
                        if (controller.text == widget.validationCode) {
                          Navigator.of(context).push(CupertinoPageRoute<void>(
                              builder: (BuildContext context) {
                            return InfoPersonal(
                                numeroTelefono: widget.numeroTelefono,codigo: widget.validationCode);
                          }));
                        } else {
                          showTopSnackBar(
                            context,
                            const CustomSnackBar.error(
                              message: "Código inválido",
                            ),
                          );
                        }
                      },
                      elevation: 0,
                      splashColor: Colors.transparent,
                      child: const Text('Verificar ahora',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(34, 34, 3, 1))),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 15,
                // ),
                // Text('Reenviar')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
