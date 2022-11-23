import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

part 'permisos_event.dart';
part 'permisos_state.dart';

class PermisosBloc extends Bloc<PermisosEvent, PermisosState> {

  StreamSubscription? gpsServicioSubscripcion;

  PermisosBloc(): super(const PermisosState(gpsConectado: false, permisoGpsActivo: false)) {

    on<OtorgarPermisosEvento>((event, emit) => emit(state.copyWith(
        gpsConectado: event.gpsConectado,
        permisoGpsActivo: event.permisoGpsActivo)));
      
    _inicio();

  }

  Future<void> _inicio() async{
      final estadoInicial = await Future.wait([
        _verEstados(),
        _verPermiso()
      ]);

      add(OtorgarPermisosEvento(estadoInicial[0],estadoInicial[1]));

  }
  
  Future<bool> _verPermiso() async{
    final hayPermiso = await Permission.location.isGranted;
    return hayPermiso;
  }

  Future<bool> _verEstados() async{

    final estaActivo = await Geolocator.isLocationServiceEnabled();

    gpsServicioSubscripcion = Geolocator.getServiceStatusStream().listen((event) {
      final ubicacionActiva = ( event.index == 1) ? true : false;
        add(OtorgarPermisosEvento(ubicacionActiva,state.permisoGpsActivo));
    });

    return estaActivo;

  }


  Future<void> preguntarPermiso() async{
    PermissionStatus status = await Permission.location.request();

    switch (status) {
      case PermissionStatus.granted:
        add(OtorgarPermisosEvento(state.gpsConectado,true));
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        add(OtorgarPermisosEvento(state.gpsConectado,true));
        openAppSettings();
    }
  }

  Future<void> abrirAjustes() async{
        openAppSettings();
  }

  @override
  Future<void> close() {
    gpsServicioSubscripcion?.cancel();
    return super.close();
  }

}
