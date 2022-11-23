import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lista_de_pantalla.dart';

void main() async{
 
 WidgetsFlutterBinding.ensureInitialized();
  await NotificacionesPush.iniciarApp();
 Firebase.initializeApp().then((value) => {
    initializeDateFormatting().then((_) => runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context)=>PermisosBloc())
      ],
      child: const MiRuta())
  ))
  });
  
}



// class FrogColor extends InheritedWidget {
//   const FrogColor({
//     required Key key,
//     required this.color,
//     required Widget child,
//   })  : assert(color != null),
//         assert(child != null),
//         super(key: key, child: child);

//   final Color color;

//   static FrogColor of(BuildContext context) {
//     return context.inheritFromWidgetOfExactType(FrogColor);
//   }

//   @override
//   bool updateShouldNotify(FrogColor old) {
//     return color != old.color;
//   }
// }

class MiRuta extends StatefulWidget {
  const MiRuta({Key? key}) : super(key: key);

  @override
  State<MiRuta> createState() => _MiRutaState();
}

class _MiRutaState extends State<MiRuta> {
  
    @override
  void initState() {
    // TODO: implement initState
    super.initState();


    //context
    NotificacionesPush.messageStream.listen((mensaje) {
      print('Mi Ruta: $mensaje');
     });
  }


  // This widget is the root of your application.
  @override
  void dispose() {
    // streamModoUsuario.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        dark: ThemeData.dark(),
        light: ThemeData.light(),        
        initial: AdaptiveThemeMode.light,
        builder: (theme, darkTheme) {
          return MaterialApp(
            title: 'Mi Ruta',
            darkTheme: darkTheme,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Clan'),
            routes: {
            '/control': (_) => const Control()
    
      },
      initialRoute: '/control',
          );
        });
  }
}

