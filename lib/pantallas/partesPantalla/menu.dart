import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miruta/lista_de_pantalla.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late String nombreUsuario = '';
  late String dniUsuario;
  late String imagenPerfil = 'assets/images/png/default/usuario.png';
  late String estadoUsuario = '';
  late String modoUsuario = '';
  bool estaBuscandoDatosChofer = false;
  String modousuarioapp = '1';

  /// `true` chofer
  ///
  /// `false` usaurio normal
  bool estadoUsuarioCaptura = true;

  @override
  void initState() {
    obtenerDataSesion();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void obtenerDataSesion() async {
    const storage = FlutterSecureStorage();
    String? value = await storage.read(key: 'SESSION');
    String? valueModo = await storage.read(key: 'Modo');
    Map<String, dynamic> usuarioResponse = json.decode(value ?? '');
    print('llllllllllllllll');
    print(usuarioResponse);
    if (valueModo == '0') {
      setState(() {
        modousuarioapp = '0';
        estadoUsuario = 'Cambiar a Cliente';
        modoUsuario = 'MODO CONDUCTOR';
        nombreUsuario = usuarioResponse['names'].split(' ').toList()[0] +
            ' ' +
            usuarioResponse['last_name_father'];
        imagenPerfil = usuarioResponse['imageUrl'];
      });
    } else {
      setState(() {
        modousuarioapp = '1';
        estadoUsuario = 'Cambiar a Conductor';
        modoUsuario = 'MODO CLIENTE';
        nombreUsuario = usuarioResponse['names'].split(' ').toList()[0] +
            ' ' +
            usuarioResponse['last_name_father'];
        imagenPerfil = usuarioResponse['imageUrl'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // dynamic miVis = GeneralWidget.of(context)?.esConductor??true;
    // final miModoUsuario = GeneralWidget.of(context)?.esConductor==null?true:GeneralWidget.of(context)!.esConductor;
    return Scaffold(
      extendBodyBehindAppBar: true,
      // resizeToAvoidBottomInset: false,
      drawerScrimColor: const Color.fromRGBO(21, 21, 21, .4),
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
                  color: const Color.fromRGBO(21, 21, 21, 1),
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromARGB(36, 0, 0, 0),
                        blurRadius: 5,
                        spreadRadius: 1),
                  ],
                ),
                // color: Colors.white,
                height: 44,
                width: 44,
                child: Image.asset(
                  'assets/images/png/iconos/menu.png',
                  scale: 2.8,
                  color: const Color.fromRGBO(253, 189, 16, 1),
                ),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          })),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.70,
        child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Stack(children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 120,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        colors: [
                          Color.fromRGBO(21, 21, 21, 1),
                          Color.fromRGBO(21, 21, 21, 1),
                        ],
                      ))),
                  Positioned(
                      right: 35,
                      bottom: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromRGBO(253, 189, 16, 1),
                              width: 0),
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white,
                        ),
                        width: 40,
                        height: 40,
                        child: ClipOval(
                          child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      imagenPerfil=='assets/images/png/default/usuario.png'?'https://res.cloudinary.com/jrdotcom/image/upload/v1668389036/miRuta/s_rvhwte.png':imagenPerfil),
                                  backgroundColor:
                                      const Color.fromARGB(255, 209, 215, 219),
                                )
                          // imagenPerfil == ''
                          //     ? Image.network(imagenPerfil)
                          //     : Image.asset(
                          //         imagenPerfil,
                          //         fit: BoxFit.cover,
                          //       ),
                        ),
                      )),
                  const Positioned(
                      right: 10,
                      bottom: 40,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                        color: Color.fromARGB(255, 151, 151, 151),
                      )),
                  Positioned(
                    left: 30,
                    bottom: 53,
                    child: Text(
                      modoUsuario,
                      style: const TextStyle(
                          color: Color.fromRGBO(253, 189, 16, 1),
                          fontSize: 9,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    bottom: 33,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.39,
                      child: Text(
                        nombreUsuario.toUpperCase(),
                        maxLines: 1,softWrap: false, overflow: TextOverflow.fade,
                        style: const TextStyle(

                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ]),
                modousuarioapp == '1'
                    ? const OpcionesModoCliente()
                    : const OpcionesModoConductor(),
                modousuarioapp == '1'
                    ? SizedBox(
                        height: 90,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Material(
                            color: const Color.fromARGB(0, 21, 21, 21),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  border: Border.all(
                                      color:
                                          const Color.fromRGBO(21, 21, 21, 1),
                                      width: 2)),
                              child: MaterialButton(
                                height: 50,
                                onPressed: () async {
                                  const storage = FlutterSecureStorage();
                                  final session = Session();

                                  String? value =
                                      await storage.read(key: 'SESSION');
                                  Map<String, dynamic> usuarioResponse =
                                      json.decode(value ?? '');
                                  print('llllllllllllllll');
                                  print(usuarioResponse);

                                  // setState(() {
                                  //   estaBuscandoDatosChofer = true;
                                  // });

                                  if (usuarioResponse['iIdChofer'] != '0') {
                                    var miCon = await Lib().obtenerEstadoChofer(
                                        usuarioResponse['iIdChofer']);
                                    Map<String, dynamic> estadosolicitudChofer =
                                        json.decode(miCon ?? '');
                                    if (estadosolicitudChofer['data'][0]
                                            ['iEstado'] ==
                                        'Aprobado') {
                                      showTopSnackBar(
                                        context,
                                        const CustomSnackBar.success(
                                          message:
                                              "Bienvenido a MiRuta Conductor",
                                        ),
                                      );
                                      await session.modoUsuario(0);
                                      Navigator.of(context).pushAndRemoveUntil(
                                          CupertinoPageRoute<void>(
                                              builder: (BuildContext context) {
                                        return const Control();
                                      }), (Route<dynamic> route) => false);
                                    } else if (estadosolicitudChofer['data'][0]
                                            ['iEstado'] ==
                                        'Rechazado') {
                                      showTopSnackBar(
                                        context,
                                        const CustomSnackBar.error(
                                          message:
                                              "Tu solicitud ha sido rechazada. Lo sentimos.",
                                        ),
                                      );
                                    } else {
                                      showTopSnackBar(
                                        context,
                                        const CustomSnackBar.info(
                                          message:
                                              "Tu solicitud está en cola para evaluación.",
                                        ),
                                      );
                                    }
                                  } else {
                                    showDialog<void>(
                                      context: context, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'No cuentas con un perfil de conductor',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16),
                                          ),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: const <Widget>[
                                                Text(
                                                  '¿Quieres solicitar una vacante como conductor?',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color.fromARGB(
                                                          128, 21, 21, 21)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextButton(
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'No,gracias',
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: const Color.fromRGBO(
                                                      21, 21, 21, 1),
                                                ),
                                                child: TextButton(
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      'Solicitar',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.of(context).push(
                                                        CupertinoPageRoute<
                                                                void>(
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                      return const MarcaAuto();
                                                    }));
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                  // setState(() {
                                  //   estaBuscandoDatosChofer = false;
                                  // });
                                },
                                elevation: 0,
                                splashColor: Colors.transparent,
                                child: estaBuscandoDatosChofer
                                    ? FadeIn(
                                        child: const SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color:
                                                Color.fromRGBO(21, 21, 21, 1),
                                          ),
                                        ),
                                      )
                                    : FadeIn(
                                        child: Text(estadoUsuario,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromRGBO(
                                                    21, 21, 21, 1))),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 90,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Material(
                            color: const Color.fromARGB(0, 21, 21, 21),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  border: Border.all(
                                      color:
                                          const Color.fromRGBO(21, 21, 21, 1),
                                      width: 2)),
                              child: MaterialButton(
                                height: 50,
                                onPressed: () async {
                                  final session = Session();
                                  await session.modoUsuario(1);
                                  Navigator.of(context).pushAndRemoveUntil(
                                      CupertinoPageRoute<void>(
                                          builder: (BuildContext context) {
                                    return const Control();
                                  }), (Route<dynamic> route) => false);
                                },
                                elevation: 0,
                                splashColor: Colors.transparent,
                                child: estaBuscandoDatosChofer
                                    ? FadeIn(
                                        child: const SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color:
                                                Color.fromRGBO(21, 21, 21, 1),
                                          ),
                                        ),
                                      )
                                    : FadeIn(
                                        child: Text(estadoUsuario,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromRGBO(
                                                    21, 21, 21, 1))),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            )),
      ),
      body: const Mapa(),
    );
  }
}
