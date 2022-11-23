import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miruta/lista_de_pantalla.dart';

class Registrarse extends StatefulWidget {
  const Registrarse({Key? key}) : super(key: key);

  @override
  State<Registrarse> createState() => _RegistrarseState();
}

class _RegistrarseState extends State<Registrarse> {
  dynamic telefonoController = TextEditingController();
  bool cargaRegistra = false;

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
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color.fromRGBO(252, 226, 0, 1),
          body: Stack(children: [
            Positioned(
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.35,
                child: Image.asset('assets/images/png/screen_city.png',
                    fit: BoxFit.cover)),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Stack(children: [
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.1,
                    right: MediaQuery.of(context).size.width * 0.1,
                    top: MediaQuery.of(context).size.height * 0.055,
                    child: const Text(
                      'Regístra tu número celular',
                      style: TextStyle(
                          fontFamily: 'Clan',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.1,
                    right: MediaQuery.of(context).size.width * 0.1,
                    top: MediaQuery.of(context).size.height * 0.1,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromRGBO(34, 34, 34, 1),
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: TextFormField(
                        controller: telefonoController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone_iphone_rounded,
                                color: Color.fromRGBO(21, 21, 21, 1),
                                size: 20.0),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            fillColor: Colors.white,
                            hintText: "Teléfono",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.1,
                    right: MediaQuery.of(context).size.width * 0.1,
                    top: MediaQuery.of(context).size.height * 0.2,
                    child: Center(
                      child: Material(
                        color: const Color.fromRGBO(34, 34, 34, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: MaterialButton(
                          // color: Color.fromARGB(255, 0, 0, 0),
                          minWidth: MediaQuery.of(context).size.width * 0.8,
                          height: 60,
                          onPressed: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            setState(() {
                              cargaRegistra = true;
                            });
                            if (telefonoController.text.trim().isEmpty) {
                              setState(() {
                                cargaRegistra = false;
                              });
                              showTopSnackBar(
                                context,
                                const CustomSnackBar.error(
                                  message: "Completa el campo de teléfono",
                                ),
                              );
                            } else if (telefonoController.text.trim().length !=
                                9) {
                              setState(() {
                                cargaRegistra = false;
                              });
                              showTopSnackBar(
                                context,
                                const CustomSnackBar.error(
                                  message: "Ingresa un número válido",
                                ),
                              );
                            } else {
                              String codeSent = await Lib()
                                  .enviarCodigodeVerificacion(
                                      telefonoController.text);
                              setState(() {
                                cargaRegistra = false;
                              });
                              if (codeSent.isEmpty) {
                                showTopSnackBar(
                                  context,
                                  const CustomSnackBar.error(
                                    message: "No se pudo enviar el código",
                                  ),
                                );
                                return;
                              } else {
                                Navigator.of(context).push(
                                    CupertinoPageRoute<void>(
                                        builder: (BuildContext context) {
                                  return VerificacionCelular(
                                      numeroTelefono: telefonoController.text,
                                      validationCode: codeSent);
                                }));
                              }
                            }
                          },
                          elevation: 0,
                          splashColor: Colors.transparent,
                          child: cargaRegistra
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.amber,
                                    strokeWidth: 2,
                                  ))
                              : const Text('Registrar',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Color.fromARGB(255, 255, 255, 255))),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.1,
                    right: MediaQuery.of(context).size.width * 0.1,
                    top: MediaQuery.of(context).size.height * 0.29,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                            CupertinoPageRoute<void>(
                                builder: (BuildContext context) {
                          return const Ingresar();
                        }));
                      },
                      child: Container(
                        width: 100,
                        height: 40,
                        color: Colors.transparent,
                        child: const Center(
                          child: Text('Ya tengo una cuenta',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(169, 85, 85, 85))),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            // Positioned(
            //   top: MediaQuery.of(context).size.height * 0.265,
            //   left: 25,
            //   child: Image.asset('assets/images/png/login/auto.png',
            //       width: MediaQuery.of(context).size.width * 0.4,
            //       fit: BoxFit.contain),
            // ),
            Positioned(
              top: 30,
              left: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.transparent,
                  child: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
