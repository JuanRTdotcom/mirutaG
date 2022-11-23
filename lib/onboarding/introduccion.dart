import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:miruta/lista_de_pantalla.dart';

// ignore: use_key_in_widget_constructors
class Introduccion extends StatefulWidget {
  @override
  State<Introduccion> createState() => _IntroduccionState();
}

class _IntroduccionState extends State<Introduccion> {
  List<PageViewModel> mispaginas() {
    return [
      PageViewModel(
        image: Image.asset('assets/images/png/onboarding/viajero.png',
            width: MediaQuery.of(context).size.width, fit: BoxFit.fitWidth),
        title: 'Hagamos un viaje',
        bodyWidget: const Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Consigue viajes a menor precio y más seguros, abordando rutas que coincidan con tu camino o destino.',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 150, 150, 150),
                    height: 1.4),
                textAlign: TextAlign.center,
              ),
            )),
        // footer: const Text('Encuentra la mejor ruta para ti')
      ),
      PageViewModel(
        image: Image.asset('assets/images/png/onboarding/eleccion.png',
            width: MediaQuery.of(context).size.width, fit: BoxFit.fitWidth),
        title: 'Siempre lo mejor',
        bodyWidget: const Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Elige la mejor opción que tengas para aprovechar tu viaje y vivir una experiencia reconfortante hasta tu destino.',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 150, 150, 150),
                    height: 1.4),
                textAlign: TextAlign.center,
              ),
            )),
        // footer: const Text('Encuentra la mejor ruta para ti')
      ),
      PageViewModel(
        image: Image.asset('assets/images/png/onboarding/gana.png',
            width: MediaQuery.of(context).size.width, fit: BoxFit.fitWidth),
        title: 'Gana dinero',
        bodyWidget: const Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Si te conviertes en conductor, podrás generar ingresos cuando los pasajeros se dirijan al mismo destino que tú.',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 150, 150, 150),
                    height: 1.4),
                textAlign: TextAlign.center,
              ),
            )),
        // footer: const Text('Encuentra la mejor ruta para ti')
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Clan'),
      title: 'Introduccion',
      home: Stack(
        children: [
          Scaffold(
            body: IntroductionScreen(
              showBackButton: false,
              showSkipButton: true,
              curve: Curves.fastLinearToSlowEaseIn,
              showNextButton: false,
              skip: const Text(
                "Saltar",
                style: TextStyle(color: Color.fromRGBO(252, 226, 0, 1)),
              ),
              done: const Text("Comenzar",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(252, 226, 0, 1))),
              onDone: () {
                Navigator.of(context).pushAndRemoveUntil(
                    CupertinoPageRoute<void>(builder: (BuildContext context) {
                  return const Principal(
                    logueadoApp: false,
                  );
                }), (Route<dynamic> route) => false);
              },
              onSkip: () {
                Navigator.of(context).pushAndRemoveUntil(
                    CupertinoPageRoute<void>(builder: (BuildContext context) {
                  return const Principal(
                    logueadoApp: false,
                  );
                }), (Route<dynamic> route) => false);
              },
              pages: mispaginas(),
              globalBackgroundColor: Colors.white,
              dotsDecorator: const DotsDecorator(
                size: Size(10.0, 10.0),
                activeColor: Color.fromRGBO(252, 226, 0, 1),
                color: Color(0xFFBDBDBD),
                activeSize: Size(22.0, 10.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
