import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:miruta/blocs/misblocs.dart';
import 'package:miruta/lista_de_pantalla.dart';

class Principal extends StatefulWidget {
  final bool logueadoApp;

  const Principal({Key? key, required this.logueadoApp}) : super(key: key);

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  bool logueado = false;

  @override
  void initState() {
    if (widget.logueadoApp == true) {
      setState(() {
        logueado = true;
      });
    } else {
      setState(() {
        logueado = false;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(fontFamily: 'Clan'),
        debugShowCheckedModeBanner: false,
        home: logueado ? const Inicio() : const Login());
  }
}

class Inicio extends StatefulWidget {
  const Inicio({
    Key? key,
  }) : super(key: key);

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<PermisosBloc, PermisosState>(
      builder: (context, state) {
        return state.todoestaBien ? const Menu() : const Permisos();
      },
    ));
  }
}
