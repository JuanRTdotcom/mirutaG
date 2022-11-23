import 'dart:async';

class StreamModoUsuario {
  final controladorStreamModoUsuario = StreamController<bool>();


/// Obtener e Iniciar stream
  Stream<bool> get streamModoUsuario => controladorStreamModoUsuario.stream;


/// Dos valores
/// 
/// `true` es Cliente
/// 
/// `false` es Conductor
  void cambiarModoCliente(bool modo){
    controladorStreamModoUsuario.add(modo);
  }


/// Cerrar Stream modo usuario
  void dispose(){
    controladorStreamModoUsuario.close();
  }
}

// class StreamMapa {
//   final controladorStreamMapa = StreamController<bool>();


// /// Obtener e Iniciar stream
//   Stream<bool> get streamModoUsuario => controladorStreamMapa.stream;


// /// Dos valores
// /// 
// /// `true` es Cliente
// /// 
// /// `false` es Conductor
//   void cambiarModoCliente(bool modo){
//     print('zzzzzzzzzzzzzzzzzzzzzz');
//     print(modo);
//   }


// /// Cerrar Stream modo usuario
//   void dispose(){
//     controladorStreamMapa.close();
//   }
// }
