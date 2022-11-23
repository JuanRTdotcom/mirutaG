part of 'permisos_bloc.dart';

class PermisosState extends Equatable {
  
  final bool gpsConectado;
  final bool permisoGpsActivo;
  
  bool get todoestaBien => gpsConectado && permisoGpsActivo;
  
  const PermisosState({
    required this.gpsConectado,
    required this.permisoGpsActivo
  });

  PermisosState copyWith({
    bool? gpsConectado,
    bool? permisoGpsActivo
  }) => PermisosState(
    gpsConectado: gpsConectado ?? this.gpsConectado, 
    permisoGpsActivo: permisoGpsActivo ?? this.permisoGpsActivo
  );

  @override
  List<Object> get props => [
    gpsConectado,
    permisoGpsActivo
  ];

  @override
  String toString() => '{ gpsConectado : $gpsConectado , permisoGpsActivo : $permisoGpsActivo }';
}

