import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:miruta/lista_de_pantalla.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Control extends StatefulWidget {
  const Control({Key? key}) : super(key: key);
  @override
  _ControlState createState() => _ControlState();
}

class _ControlState extends State<Control> with TickerProviderStateMixin {
  late AnimationController ctrll;
  final Session _session = Session();
  @override
  void initState() {
    animacionInicio();
    redireccion();
    super.initState();
  }

  void animacionInicio() {
    ctrll = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addListener(() {
        setState(() {});
      });

    ctrll.forward();
  }

  Future<void> redireccion() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    if (pref.getString('primera_vez_local') == '1') {
      Future.delayed(const Duration(milliseconds: 3200), () async {
        // FlutterSecureStorage storage = const FlutterSecureStorage();
        // await storage.deleteAll();
        final data = await _session.get();
        if (data != null) {
          Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute<void>(builder: (BuildContext context) {
            return const Principal(logueadoApp: true);
          }), (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute<void>(builder: (BuildContext context) {
            return const Principal(logueadoApp: false);
          }), (Route<dynamic> route) => false);
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 3200), () {
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute<void>(builder: (BuildContext context) {
          return Introduccion();
        }), (Route<dynamic> route) => false);
      });
    }
    await pref.setString('primera_vez_local', '1');
  }

  @override
  void dispose() {
    ctrll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(fontFamily: 'Clan'),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
              decoration:
                  const BoxDecoration(color: Color.fromRGBO(252, 226, 0, 1)),
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          duration: const Duration(milliseconds: 900),
                          child: Image.asset('assets/images/png/logo.png',
                              width: 190, height: 190, fit: BoxFit.contain),
                        ),
                        // FadeInDown(
                        //   duration: const Duration(milliseconds: 1000),
                        //   child: const Text('Mi Ruta',
                        //       style: TextStyle(
                        //           fontSize: 42,
                        //           fontWeight: FontWeight.w600,
                        //           color: Color.fromRGBO(34, 43, 62, 1))),
                        // ),
                        const SizedBox(
                          height: 100,
                        ),
                        FadeIn(
                          duration: const Duration(milliseconds: 1100),
                          delay: const Duration(milliseconds: 1200),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 80),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              child: LinearProgressIndicator(
                                color: const Color.fromRGBO(34, 34, 34, 1),
                                value: ctrll.value,
                                backgroundColor:
                                    const Color.fromRGBO(34, 34, 34, .5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: FadeInUpBig(
                        duration: const Duration(milliseconds: 800),
                        child: Image.asset('assets/images/png/screen_city.png',
                            width: double.infinity, fit: BoxFit.cover),
                      )),
                  // Center(
                  //   child: Image.asset('assets/images/tuclinika.gif',),
                  // )
                ],
              )),
        ));
  }
}
