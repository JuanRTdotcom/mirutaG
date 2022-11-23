import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:miruta/blocs/misblocs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Permisos extends StatefulWidget {
  const Permisos({Key? key}) : super(key: key);

  @override
  State<Permisos> createState() => _PermisosState();
}

class _PermisosState extends State<Permisos> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Clan'),
        home: BlocBuilder<PermisosBloc, PermisosState>(
          builder: (context, state) {
            return !state.gpsConectado
                ? const Geolocalizacion()
                : const Ubicacion();
          },
        ));
  }
}

class Ubicacion extends StatelessWidget {
  const Ubicacion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iniciosesionboton = ElevatedButton.styleFrom(
      primary: const Color.fromRGBO(255, 188, 47, 1),
      onPrimary: const Color.fromRGBO(36, 42, 56, 1),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              Center(
                child: ZoomIn(
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/png/permisos/gps.png',
                          width: MediaQuery.of(context).size.width * 0.6,
                          fit: BoxFit.contain),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Habilita tu ubicación',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(34, 43, 62, 1))),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Necesitas habilitar la opción de compartir ubicación para usar Mi Ruta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 194, 191, 191),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            final blockPermisos =
                                BlocProvider.of<PermisosBloc>(context);
                            blockPermisos.preguntarPermiso();
                          },
                          style: iniciosesionboton,
                          child: Ink(
                            child: Container(
                              width: 200,
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: const Text('Permitir ubicación',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800,color: Color.fromRGBO(34, 43, 62, 1))),
                            ),
                          )),
                      const SizedBox(
                        height: 5,
                      ),
                      MaterialButton(
                        onPressed: () async {
                          final SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          await pref.clear();
                        },
                        elevation: 0,
                        splashColor: Colors.transparent,
                        child: const Text('Ahora no',
                            style: TextStyle(
                                // fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 158, 158, 158))),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class Geolocalizacion extends StatelessWidget {
  const Geolocalizacion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iniciosesionboton = ElevatedButton.styleFrom(
      primary: const Color.fromRGBO(255, 188, 47, 1),
      onPrimary: const Color.fromRGBO(36, 42, 56, 1),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              Center(
                child: ZoomIn(
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('¡Ay!',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(34, 43, 62, 1))),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Para utilizar Mi Ruta debes activar la ubicación de tu dispositivo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 194, 191, 191),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Ve a Ajustes > Ubicación > Activar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 194, 191, 191),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
