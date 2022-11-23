
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:miruta/lista_de_pantalla.dart';

class Mapa_usuario_medio_pantalla extends StatelessWidget {
  const Mapa_usuario_medio_pantalla({
    Key? key,
    required this.imagenPerfil,
  }) : super(key: key);

  final String imagenPerfil;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50,
        height: 110,
        child: Stack(
          children: [
            Positioned(
              left: 24,
              child: Container(
                width: 2,
                height: 55,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(253, 189, 16, 1),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 5,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(253, 189, 16, 1),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
            ),
            Positioned(
              top: 2,
              left: 7,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36.0),
                  child: 
                  imagenPerfil != 'assets/images/png/default/usuario.png'
                      ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      imagenPerfil==''?'https://res.cloudinary.com/jrdotcom/image/upload/v1668389036/miRuta/s_rvhwte.png':imagenPerfil),
                                  backgroundColor:
                                      const Color.fromARGB(255, 209, 215, 219),
                                )
                      : Image.asset(
                          imagenPerfil,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class Mapa_popup_nombre_calles extends StatelessWidget {
  const Mapa_popup_nombre_calles({
    Key? key,
    required this.moviendoPin,
    required this.buscandoUbicacionNombre,
    required this.miLugar,
  }) : super(key: key);

  final bool moviendoPin;
  final bool buscandoUbicacionNombre;
  final String miLugar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        // width: 50,

        constraints: const BoxConstraints(
          minWidth: 0,
          maxWidth: 250,
        ),
        height: 190,
        child: Column(
          children: [
            Center(
              child: moviendoPin
                  ? const SizedBox(width: 0, height: 0)
                  : buscandoUbicacionNombre
                      ? FadeIn(
                          duration: const Duration(milliseconds: 250),
                          child: Column(
                            children: [
                              Container(
                                // duration: const Duration(milliseconds: 250),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(8)),
                                  color:
                                      Color.fromRGBO(21, 21, 21, 1),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 10),
                                  child: SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Color.fromRGBO(
                                          253, 189, 16, 1),
                                    ),
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/images/png/default/tool.png',
                                width: 12,
                                color: const Color.fromRGBO(
                                    20, 20, 20, 1),
                              )
                            ],
                          ),
                        )
                      : FadeIn(
                          duration: const Duration(milliseconds: 150),
                          child: Column(
                            children: [
                              Container(
                                // duration: const Duration(milliseconds: 250),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(8)),
                                  color:
                                      Color.fromRGBO(21, 21, 21, 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 10),
                                  child: Text(
                                    miLugar.trim() == ','
                                        ? ''
                                        : miLugar,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/images/png/default/tool.png',
                                width: 12,
                                color: const Color.fromRGBO(
                                    20, 20, 20, 1),
                              )
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}



class Mapa_boton_ubicacion_actual extends StatelessWidget {
  

  final double inicioBotonMiUbicacion;
  final dynamic mapaControlador;

  const Mapa_boton_ubicacion_actual({Key? key, required this.inicioBotonMiUbicacion, this.mapaControlador}) : super(key: key);  

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 360),
      curve: Curves.fastOutSlowIn,
      right: 20,
      bottom: inicioBotonMiUbicacion - 10,
      child: GestureDetector(
        onTap: () => Lib().obtenerUbicacionInicial(mapaControlador),
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Color.fromRGBO(21, 21, 21, 1),
              boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(36, 0, 0, 0),
                    blurRadius: 5,
                    spreadRadius: 1),
              ]),
          // width: MediaQuery.of(context).size.width * 0.5,
          height: 40,
          width: 40,
          child: Center(
            child: Image.asset(
              'assets/images/png/iconos/target.png',
              width: 24,
              height: 24,
              color: const Color.fromRGBO(253, 189, 16, 1),
            ),
          ),
        ),
      ),
    );
  }
}


class Mapa_fondo_a_donde_vamos extends StatelessWidget {
  const Mapa_fondo_a_donde_vamos({
    Key? key,
    required this.posicionBuscador,
    required this.nombre,
  }) : super(key: key);

  final double posicionBuscador;
  final String nombre;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      left: 0,
      right: 0,
      bottom: posicionBuscador,
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10)),
            color: Color.fromRGBO(21, 21, 21, 1),
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(33, 255, 255, 255),
                  blurRadius: 5,
                  spreadRadius: 1),
            ]),
        // width: MediaQuery.of(context).size.width * 0.5,
        height: 120,
        child:  Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30),
          child: Text(nombre,
              style: const TextStyle(
                  color: Color.fromRGBO(253, 189, 16, 1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
class Mapa_fondo_iniciar_viaje extends StatelessWidget {
  const Mapa_fondo_iniciar_viaje({
    Key? key,
    required this.posicionBuscador,
    required this.nombre,
  }) : super(key: key);

  final double posicionBuscador;
  final String nombre;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      left: 0,
      right: 0,
      bottom: posicionBuscador,
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10)),
            color: Color.fromRGBO(21, 21, 21, 1),
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(33, 255, 255, 255),
                  blurRadius: 5,
                  spreadRadius: 1),
            ]),
        // width: MediaQuery.of(context).size.width * 0.5,
        height: 120,
        child:  Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30),
          child: Text(nombre,
              style: const TextStyle(
                  color: Color.fromRGBO(253, 189, 16, 1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}



class IconoPinTextodentro extends StatelessWidget {

  const IconoPinTextodentro({
    Key? key,
    required this.textoIcono,
  }) : super(key: key);

  final String textoIcono;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 35,
          width: 30,
          child: Stack(
            children: [
              ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20),
                  child: Container(
                    width: 30,
                    height: 30,
                    color: const Color.fromARGB(
                        255, 21, 21, 21),
                    child: Center(
                        child: Text(
                      textoIcono,
                      style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w600),
                    )),
                  )),
              Positioned(
                bottom: 2,
                left: 9,
                child: Image.asset(
                  'assets/images/png/default/tool.png',
                  width: 12,
                  color: const Color.fromRGBO(
                      20, 20, 20, 1),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
