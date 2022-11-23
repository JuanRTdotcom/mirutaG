import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miruta/lista_de_pantalla.dart';

class OpcionesModoCliente extends StatelessWidget {
  const OpcionesModoCliente({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [
            Color.fromRGBO(21, 21, 21, 1),
            Color.fromRGBO(21, 21, 21, 1),
          ],
        )),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.only(topRight: Radius.circular(15)),
          child: Container(
            color: Colors.white,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: <Widget>[
                const SizedBox(
                  height: 40,
                ),
                FadeIn(
                  delay: const Duration(milliseconds: 50),
                  duration: const Duration(milliseconds: 300),
                  child: ListTile(
                    dense: true,
                    selected: true,
                    selectedColor: Colors.red,
                    selectedTileColor: Colors.red,
                    minLeadingWidth: 0,
                    leading: Image.asset(
                      'assets/images/png/menu/mundo.png',
                      width: 16,
                      height: 16,
                      // color: const Color.fromRGBO(21, 21, 21, 1),
                    ),
                    contentPadding: const EdgeInsets.only(
                        top: 10, left: 30, right: 30),
                    title: const Text(
                      'Mapa',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 21, 21, 1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                FadeIn(
                  delay: const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 300),
                  child: ListTile(
                    dense: true,
                    minLeadingWidth: 0,
                    leading: Image.asset(
                      'assets/images/png/menu/viaje.png',
                      width: 16,
                      height: 16,
                      color: Colors.orange,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 30),
                    title: const Text(
                      'Mis Viajes',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 21, 21, 1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                FadeIn(
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 300),
                  child: ListTile(
                    onTap: () async{
                      const storage = FlutterSecureStorage();
                      String? value = await storage.read(key: 'SESSION');
                      String? valueModo = await storage.read(key: 'Modo');
                      Map<String, dynamic> usuarioResponse = json.decode(value ?? '');
                      
                      Navigator.of(context).push(CupertinoPageRoute<void>(
                              builder: (BuildContext context) {
                            return SolicitudDeAsiento(
                                idRuta: usuarioResponse['id'],
                                origen: 'PASAJERO',
                                );
                          }));
                    },
                    dense: true,
                    minLeadingWidth: 0,
                    leading: Image.asset(
                      'assets/images/png/menu/notificaciones.png',
                      width: 16,
                      height: 16,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 30),
                    title: const Text(
                      'Notificaciones',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 21, 21, 1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                FadeIn(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 300),
                  child: ListTile(
                    dense: true,
                    minLeadingWidth: 0,
                    leading: Image.asset(
                      'assets/images/png/menu/seguridad.png',
                      width: 16,
                      height: 16,
                      color: const Color.fromRGBO(1, 220, 128, 1),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 30),
                    title: const Text(
                      'Centro de seguridad',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 21, 21, 1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                FadeIn(
                  delay: const Duration(milliseconds: 250),
                  duration: const Duration(milliseconds: 300),
                  child: ListTile(
                    dense: true,
                    minLeadingWidth: 0,
                    leading: Image.asset(
                      'assets/images/png/menu/configuraciones.png',
                      width: 16,
                      height: 16,
                      color: const Color.fromRGBO(2, 186, 222, 1),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 30),
                    title: const Text(
                      'Configuración',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 21, 21, 1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                FadeIn(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 300),
                  child: ListTile(
                    dense: true,
                    minLeadingWidth: 0,
                    leading: Image.asset(
                      'assets/images/png/menu/salir.png',
                      width: 16,
                      height: 16,
                      color: Colors.red,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 30),
                    title: const Text(
                      'Cerrar sesión',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 21, 21, 1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () async {
                      FlutterSecureStorage storage =
                          const FlutterSecureStorage();
                      await storage.deleteAll();
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute<void>(
                              builder: (BuildContext context) {
                        return const Control();
                      }), (Route<dynamic> route) => false);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
