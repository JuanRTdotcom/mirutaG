// session
export 'servicios/sesion.dart';
export 'servicios/libreria.dart';

// extensiones
export 'servicios/datetime_extension.dart';


// onboarding
export 'onboarding/introduccion.dart';

// pantallas
export 'pantallas/principal.dart';
export 'pantallas/permisos.dart';
export 'pantallas/mapa.dart';
export 'pantallas/login.dart';
export 'pantallas/partesPantalla/menu.dart';
export 'pantallas/ajustes.dart';
export 'pantallas/ingreso/ingresar.dart';
export 'pantallas/ingreso/verifica_numero_ingreso.dart';
export 'pantallas/registro/cliente/registrarse.dart';
export 'pantallas/registro/cliente/verifica_numero.dart';
export 'pantallas/registro/cliente/verifica_informacion_basica.dart';
export 'pantallas/partesPantalla/ModoCliente/rating.dart';
export 'pantallas/registro/conductor/marca_auto.dart';
export 'pantallas/partesPantalla/ModoConductor/misRutas.dart';
export 'pantallas/partesPantalla/ModoConductor/miSolicitudDeAsiento.dart';
export 'pantallas/partesPantalla/ModoConductor/gestionRutas.dart';
export 'pantallas/partesPantalla/ModoConductor/misPasajeros.dart';


// main
export 'control.dart';

// firebase
export 'package:cloud_firestore/cloud_firestore.dart';

// notificaciones
export 'servicios/notificaciones.dart';

//widgets
export 'pantallas/partesCodigo/widgets_generales.dart';
export 'pantallas/partesPantalla/menu_opcionesModocliente.dart';
export 'pantallas/partesPantalla/menu_opcionesModoconductor.dart';
export 'pantallas/partesPantalla/ModoConductor/verMapaRuta.dart';
export 'pantallas/partesPantalla/ModoConductor/miBilletera.dart';
export 'pantallas/partesPantalla/ModoConductor/gestionEstadoRuta.dart';
export 'pantallas/partesPantalla/ModoConductor/infoConductor.dart';
export 'pantallas/partesPantalla/ModoConductor/verSolicitudViaje.dart';
export 'pantallas/partesPantalla/ModoConductor/nogociacionAsiento.dart';

export 'pantallas/partesPantalla/ModoCliente/rutasRecomendadas.dart';
export 'pantallas/partesPantalla/ModoCliente/solicitarAsiento.dart';


//mensaje
export 'package:top_snackbar_flutter/custom_snack_bar.dart';
export 'package:top_snackbar_flutter/tap_bounce_container.dart';
export 'package:top_snackbar_flutter/top_snack_bar.dart';
export 'package:flutter_polyline_points/flutter_polyline_points.dart';


// blocks
export 'blocs/misblocs.dart';

// variables globales



class Config{
  // static const String googleMapsApiKey = 'AIzaSyDZ2AOwCISPnE3bDvWNK_RmrRyw4yN21ys';
  static const String googleMapsApiKey = 'AIzaSyDZ2AOwCISPnE3bDvWNK_RmrRyw4yN21ys';
  // static const String language = 'es-419';
  // static const String region = 'pe';
  static const String apiHost = 'http://207.180.246.8:8080/ChasquiApp/api';
  // static const String nuevaRutaApi = 'http://23.254.217.21/ChasquiDB/public/api';
  static const String nuevaRutaApi = 'http://207.180.246.8:8080/ChasquiDB/public/api';
}
 
 
// class GeneralWidget extends InheritedWidget{
//   GeneralWidget({Key? key,  
//     required Widget child,
//     required this.esConductor,}) 
//   : super(key: key, child: child);

//   bool esConductor;


//   static GeneralWidget? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<GeneralWidget>();
//   // static GeneralWidget of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<GeneralWidget>()??GeneralWidget(child: context.widget, esConductor: true);

//   @override
//   bool updateShouldNotify(covariant GeneralWidget oldWidget) => oldWidget.esConductor != esConductor;
// }