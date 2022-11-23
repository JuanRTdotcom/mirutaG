part of 'permisos_bloc.dart';

abstract class PermisosEvent extends Equatable {
  const PermisosEvent();

  @override
  List<Object> get props => [];
}


class OtorgarPermisosEvento extends PermisosEvent {
  final bool gpsConectado;
  final bool permisoGpsActivo;

  const OtorgarPermisosEvento(this.gpsConectado, this.permisoGpsActivo);
}