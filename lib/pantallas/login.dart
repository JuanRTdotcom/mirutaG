import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miruta/lista_de_pantalla.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}



class _LoginState extends State<Login> {

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Clan'),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(252, 226, 0, 1),
        body: Stack(
          children: [
            const SizedBox(
              height: double.infinity,
              width: double.infinity,
            ),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.123,
                left: 20,
                child: const Text(
                  'Bienvenido',
                  style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Color.fromRGBO(34, 34, 34, 1)),
                )),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.175,
                left: 20,
                child: const Text(
                  'Comienza a disfrutar los viajes',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(34, 34, 34, 1)),
                )),
              Image.asset('assets/images/png/login/nubes.png',
                  width: double.infinity, fit: BoxFit.contain),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.44,
              right: 0,
              child: Image.asset('assets/images/png/login/edificios.png',
                  width: MediaQuery.of(context).size.width * 0.5,
                  fit: BoxFit.contain),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.40,
              left: 0,
              child: Image.asset('assets/images/png/login/planta.png',
                  width: MediaQuery.of(context).size.width * 0.2,
                  fit: BoxFit.contain),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.36,
              right: 0,
              child: Image.asset('assets/images/png/login/corte.png',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain),
            ),
            Positioned(
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.39,
                decoration:
                    const BoxDecoration(color: Color.fromRGBO(220, 197, 0, 1)),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.36,
              left: 25,
              child: Hero(
                tag: 'autoInicio',
                child: Image.asset('assets/images/png/login/auto.png',
                    width: MediaQuery.of(context).size.width * 0.4,
                    fit: BoxFit.contain),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).size.height * 0.2,
              child: Center(
                child: Material(
                  color: const Color.fromRGBO(34, 34, 34, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: MaterialButton(
                    // color: Color.fromARGB(255, 0, 0, 0),
                    minWidth: MediaQuery.of(context).size.width * 0.8,
                    height: 60,
                    onPressed: () {
                      Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                              builder: (BuildContext context) {
                        return const Ingresar();
                      }));
                      // Navigator.of(context).pushAndRemoveUntil(
                      //     CupertinoPageRoute<Null>(
                      //         builder: (BuildContext context) {
                      //   return const Inicio();
                      // }), (Route<dynamic> route) => false);
                    },
                    elevation: 0,
                    splashColor: Colors.transparent,
                    child: const Text('Ingresar',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 255, 255, 255))),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).size.height * 0.1,
              child: Center(
                child: Material(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: MaterialButton(
                    // color: Color.fromARGB(255, 0, 0, 0),
                    minWidth: MediaQuery.of(context).size.width * 0.8,
                    height: 60,
                    onPressed: () async {
                      Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                              builder: (BuildContext context) {
                        return const Registrarse();
                      }));
                    },
                    elevation: 0,
                    splashColor: Colors.transparent,
                    child: const Text('Registrarse',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(34, 34, 34, 1))),
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
