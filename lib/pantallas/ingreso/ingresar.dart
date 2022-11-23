import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miruta/lista_de_pantalla.dart';

class Ingresar extends StatefulWidget {
  const Ingresar({Key? key}) : super(key: key);

  @override
  State<Ingresar> createState() => _IngresarState();
}

class _IngresarState extends State<Ingresar> {
  dynamic numeroController = TextEditingController();
  bool cargaRegistra = false;

  @override
  Widget build(BuildContext context) {
    final FocusScopeNode focus = FocusScope.of(context);
    return MaterialApp(
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
              bottom: MediaQuery.of(context).size.height * 0.65,
              right: 0,
              child: Image.asset('assets/images/png/login/edificios.png',
                  width: MediaQuery.of(context).size.width * 0.45,
                  fit: BoxFit.contain),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.85,
              left: MediaQuery.of(context).size.width * -0.1,
              child: Image.asset('assets/images/png/login/planta.png',
                  width: MediaQuery.of(context).size.width * 0.2,
                  fit: BoxFit.contain),
            ),
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
                    top: MediaQuery.of(context).size.height * 0.07,
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
                      child: TextField(
                        controller: numeroController,
                        style: const TextStyle(fontSize: 14),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            fillColor: Colors.white,
                            hintText: "Celular ( +51 )",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.1,
                    right: MediaQuery.of(context).size.width * 0.1,
                    top: MediaQuery.of(context).size.height * 0.17,
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









                          //   bool miIngreso =
                          //     await Lib().iniciarSesion(numeroController.text);
                          // if (miIngreso) {
                          //   Navigator.of(context).pushAndRemoveUntil(
                          //       CupertinoPageRoute<void>(
                          //           builder: (BuildContext context) {
                          //     return const Principal(logueadoApp: true);
                          //   }), (Route<dynamic> route) => false);
                          // }









                            if (numeroController.text.trim().isEmpty) {
                              setState(() {
                                cargaRegistra = false;
                              });
                              showTopSnackBar(
                                context,
                                const CustomSnackBar.error(
                                  message: "Completa el campo de celular",
                                ),
                              );
                            } else if (numeroController.text.trim().length !=
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
                              dynamic codeSent = await Lib()
                                  .enviarCodigodeAcceso(numeroController.text);
              
                              setState(() {
                                cargaRegistra = false;
                              });
                              if (!codeSent.isEmpty) {
                              // if (codeSent.isEmpty) {
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
                                    return VerificacionCelularIngreso(
                                        numeroTelefono: numeroController.text,
                                        validationCode: '123456');
                                        }));
                                // if (codeSent['success'] == true) {
                                //   Navigator.of(context).push(
                                //       CupertinoPageRoute<void>(
                                //           builder: (BuildContext context) {
                                //     return VerificacionCelularIngreso(
                                //         numeroTelefono: numeroController.text,
                                //         validationCode: codeSent['data']
                                //             ['code']);
                                //   }));
                                // } else {
                                //   showTopSnackBar(
                                //     context,
                                //     const CustomSnackBar.error(
                                //       message:
                                //           "Este número no está registrado. Registrate primero.",
                                //     ),
                                //   );
                                // }
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
                              : const Text('Ingresar',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Color.fromARGB(255, 255, 255, 255))),
                        ),
                      ),
                    ),
                  ),
                  // Positioned(
                  //   left: MediaQuery.of(context).size.width * 0.1,
                  //   right: MediaQuery.of(context).size.width * 0.1,
                  //   top: MediaQuery.of(context).size.height * 0.275,
                  //   child: const Center(
                  //     child: Text('¿Olvidaste tu contraseña?',
                  //         style: TextStyle(
                  //             fontSize: 14,
                  //             fontWeight: FontWeight.w400,
                  //             color: Color.fromARGB(169, 34, 34, 34))),
                  //   ),
                  // ),
                ]),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.265,
              left: 25,
              child: Hero(
                tag: 'autoInicio',
                child: Image.asset('assets/images/png/login/auto.png',
                    width: MediaQuery.of(context).size.width * 0.4,
                    fit: BoxFit.contain),
              ),
            ),
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
