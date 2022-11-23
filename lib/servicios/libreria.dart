import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miruta/lista_de_pantalla.dart';
import 'package:http/http.dart' as http;

class Lib {
  final storage = const FlutterSecureStorage();

  Future<bool> registrarUsuario(
      String dni,
      String nombre,
      String apellidoPaterno,
      String apellidoMaterno,
      String fechaNacimiento,
      String sexo,
      String direccion,
      String referencia,
      String celular,
      String correo,
      String password,
      String tipoDispositivo,
      String marca,
      String nombreDispositivo,
      String imei,
      String token,
      String code) async {
    String url =
        '${Config.apiHost}/api_setRegistroUsuario.php?Dni=$dni&Nombre=$nombre&ApellidoP=$apellidoPaterno&ApellidoM=$apellidoMaterno&FecNac=$fechaNacimiento&Sexo=$sexo&Dirección=$direccion&Referencia=$referencia&Telefono='
        '&Celular=$celular&Correo=$correo&Password=$password&iTipoDispositivo=$tipoDispositivo&iMarca=$marca&vchNombreD=$nombreDispositivo&Imei=$imei&TokenD=$token&codeVerification=$code';
    Response response;
    var dio = Dio();
    try {
      response = await dio.get(url);
    } catch (e) {
      return false;
    }

    Map<String, dynamic> usuarioResponse = json.decode(response.data);
    if (!usuarioResponse['success']) return false;

    const urlLogin = '${Config.nuevaRutaApi}/App/obtenerLogin';
    Response responseGet;
    var dioLog = Dio();
    try {
      responseGet =
          await dioLog.post(urlLogin, data: {'dni': dni, 'token': token});
    } catch (e) {
      return false;
    }
    if (!responseGet.data['success']) return false;
    final misDataUsuario = responseGet.data;
    final session = Session();
    session.clear();
    await session.set(
        misDataUsuario['data']['iIdUsuario'].toString(),
        dni,
        nombre,
        apellidoPaterno,
        apellidoMaterno,
        celular,
        correo,
        password,
        misDataUsuario['data']['urlImage'] ??
            'assets/images/png/default/usuario.png',
        misDataUsuario['data']['sexo'] ?? '',
        misDataUsuario['data']['iIdChofer'] ?? '0',
        code,
        misDataUsuario['data']['fechaNacimiento'] ?? '',
        misDataUsuario['data']['fechaRegistroUsuario'] ?? '',
        misDataUsuario['data']['direccion'] ?? '',
        misDataUsuario['data']['referencia'] ?? '');

    await session.modoUsuario(1);

    return true;
  }

  Future<bool> iniciarSesion(String numeroTelefono) async {
    Response response;
    var dio = Dio();
    const url = '${Config.nuevaRutaApi}/auth/loginDos';
    response = await dio
        .post(url, data: {'cellphone': numeroTelefono, 'token': 'zzz'});

    if (response.data['success']) {
      final session = Session();
      session.clear();
      await session.set(
          response.data['data']['iIdUsuario'] ?? '',
          response.data['data']['vchDni'] ?? '',
          response.data['data']['vchNombres'] ?? '',
          response.data['data']['vchApellidoP'] ?? '',
          response.data['data']['vchApellidoM'] ?? '',
          response.data['data']['vchCelular'] ?? '',
          response.data['data']['vchCorreo'] ?? '',
          response.data['data']['vchPassword'] ?? '',
          response.data['data']['urlImage'] ??
              'assets/images/png/default/usuario.png',
          response.data['data']['sexo'] ?? '',
          response.data['data']['iIdChofer'] ?? '0',
          '123456',
          response.data['data']['fechaNacimiento'] ?? '',
          response.data['data']['fechaRegistroUsuario'] ?? '',
          response.data['data']['direccion'] ?? '',
          response.data['data']['referencia'] ?? '');

      await session.modoUsuario(1);

      return true;
    } else {
      return false;
      // 932286428
    }
  }

  Future enviarCodigodeVerificacion(String numeroCelular) async {
    Response response;
    var dio = Dio();
    try {
      response = await dio.post(
          'http://207.180.246.8:8080/ChasquiDB/public/api/auth/send-code/sms',
          data: {'cellphone': numeroCelular, 'validateAuth': 'false'});

      return response.data['data']['code'];
    } catch (e) {
      return '';
    }
  }

  Future enviarCodigodeAcceso(String numeroCelular) async {
    Response response;
    var dio = Dio();
    try {
      response = await dio.post(
          'http://207.180.246.8:8080/ChasquiDB/public/api/auth/send-code/sms',
          data: {'cellphone': numeroCelular, 'validateAuth': 'false'});

      return response.data;
    } catch (e) {
      return '';
    }
  }

  Future<dynamic> obtenerMarca() async {
    Response response;
    var dio = Dio();
    try {
      response = await dio.post(
        'http://207.180.246.8:8080/ChasquiApp/api/api_getMarcas.php',
      );

      return response.data;
    } catch (e) {
      return '';
    }
  }

  Future<dynamic> obtenerModelo(String id) async {
    var url =
        'http://207.180.246.8:8080/ChasquiApp/api/api_getModelos.php?id=$id';
    Response response;
    var dio = Dio();

    try {
      response = await dio.post(url);

      return response.data;
    } catch (e) {
      return '';
    }
  }

  Future<dynamic> obtenerEstadoChofer(String idChofer) async {
    var url =
        'http://207.180.246.8:8080/ChasquiApp/api/api_getestadochofer.php?iIdChofer=$idChofer';

    Response response;
    var dio = Dio();
    try {
      response = await dio.post(url);

      return response.data;
    } catch (e) {
      return '';
    }
  }

  Future<String> obtenerBase64(File fileImage) async {
    String base64Image;
    List<int> imageBytes = await fileImage.readAsBytes();
    base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  Future<bool> registrarChofer(
      String dni,
      String nombre,
      String apellidoP,
      String apellidoM,
      String fecNac,
      String sexo,
      String direccion,
      String referencia,
      String telefono,
      String celular,
      String correo,
      String password,
      String tipoDispositivo,
      String marca,
      String vchNombreD,
      String imei,
      String tokenD,
      String placa,
      String modelo,
      String pasajeros,
      String anio,
      String nuevo,
      String docDni,
      String docFotoRostro,
      String docFotoAuto,
      String docAntecedentes,
      String docLicencia) async {
    try {
      Uri url = Uri.parse(
          'http://207.180.246.8:8080/ChasquiDB/public/api/registro-chofer');
      final imageUpload = http.MultipartRequest('POST', url);

      imageUpload.fields['Dni'] = dni;
      imageUpload.fields['Nombre'] = nombre;
      imageUpload.fields['ApellidoP'] = apellidoP;
      imageUpload.fields['ApellidoM'] = apellidoM;
      imageUpload.fields['FecNac'] = fecNac;
      imageUpload.fields['Sexo'] = sexo;
      imageUpload.fields['Dirección'] = direccion;
      imageUpload.fields['Referencia'] = referencia;
      imageUpload.fields['Telefono'] = celular;
      imageUpload.fields['Celular'] = celular;
      imageUpload.fields['Correo'] = correo;
      imageUpload.fields['Password'] = password;
      imageUpload.fields['iTipoDispositivo'] = tipoDispositivo;
      imageUpload.fields['iMarca'] = marca;
      imageUpload.fields['vchNombreD'] = vchNombreD;
      imageUpload.fields['Imei'] = imei;
      imageUpload.fields['TokenD'] = tokenD;
      imageUpload.fields['placa'] = placa;
      imageUpload.fields['modelo'] = modelo;
      imageUpload.fields['pasajeros'] = pasajeros;
      imageUpload.fields['año'] = anio;
      imageUpload.fields['nuevo'] = nuevo;
      imageUpload.fields['docDNI'] = docDni;
      imageUpload.fields['docFotoRostro'] = docFotoRostro;
      imageUpload.fields['docFotoAuto'] = docFotoAuto;
      imageUpload.fields['docAntecedentes'] = docAntecedentes;
      imageUpload.fields['docLicencia'] = docLicencia;

      final streamedResponse = await imageUpload.send();
      final response = await http.Response.fromStream(streamedResponse);
      dynamic miResp = json.decode(response.body);
      // final responseUsuario = estadoChoferFromJson(response.body);

      if (miResp['success']) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  void obtenerUbicacionInicial(dynamic _googleMapController) async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.3)));
  }

  Future obtenerLugares(texto) async {
    try {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$texto&inputtype=textquery&components=country:PE&key=${Config.googleMapsApiKey}';
      Response response = await Dio().get(url);
      print('pppppppppppppp');
      print(url);

      if (response.data['status'] == 'OK') {
        return response.data['predictions'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future obtenerInfoLugar(idLugar) async {
    try {
      String url =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$idLugar&key=${Config.googleMapsApiKey}';
      Response response = await Dio().get(url);
      if (response.data['status'] == 'OK') {
        print('oooooooooooooooooooooo');
        print(url);
        print(response.data['result']);
        return response.data['result'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future validarSaldoChofer(idChofer) async{
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/chofer/obtener-informacion-personal?choferId=$idChofer';
      // String url = 'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/create_J?user_id=$idUsuario&name=$nombreRuta&cost=$precio&from_la=$latiInicio&to_la=$latiFin&from_lo=$longiInicio&to_lo=$longiFin';
      Response response = await Dio().get(url);
      if (response.data['success'] == true) {
        return response.data;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
    
  }

  Future crearRuta(
    idUsuario,
    nombreRuta,
    // precio,
    // asientos,
    // fechaSalida,
    latiInicio,
    latiFin,
    longiInicio,
    longiFin,
    puntosJson,
    recogermosControlerNombre,
    llegasControladorNombre,
    direccionInicial,
    direccionFinal,
    distritoInicial,
    distritoFinal,
    provinciaInicial,
    provinciaFinal,
    regionInicial,
    regionFinal,
    direccionExactaInicial,
    direccionExactaFinal,
  ) async {
    var parametros = {
      'user_id': idUsuario,
      'name': nombreRuta,
      'cost': 0,
      'asientos':0,
      // 'fechaSalida':fechaSalida,
      'from_la': latiInicio,
      'to_la': latiFin,
      'from_lo': longiInicio,
      'to_lo': longiFin,
      'puntosJson':puntosJson,
      'detalle_nombre_inicio': recogermosControlerNombre,
      'detalle_nombre_fin': llegasControladorNombre,
      'direccion_inicio': direccionInicial,
      'direccion_fin': direccionFinal,
      'distrito_inicio': distritoInicial,
      'distrito_fin': distritoFinal,
      'provincia_inicio': provinciaInicial,
      'provincia_fin': provinciaFinal,
      'region_inicio': regionInicial,
      'region_fin': regionFinal,
      'direccion_exacta_inicio': direccionExactaInicial,
      'direccion_exacta_fin': direccionExactaFinal,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/create_J';
      // String url = 'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/create_J?user_id=$idUsuario&name=$nombreRuta&cost=$precio&from_la=$latiInicio&to_la=$latiFin&from_lo=$longiInicio&to_lo=$longiFin';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> eliminarRuta(idRuta) async {
    var parametros = {
      'id': idRuta
    };
    try {
      String url = Config.nuevaRutaApi + '/interprovincial/driver/routes/delete';
      // String url = 'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/create_J?user_id=$idUsuario&name=$nombreRuta&cost=$precio&from_la=$latiInicio&to_la=$latiFin&from_lo=$longiInicio&to_lo=$longiFin';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future listarRutas(idChofer) async {
    var parametros = {
      'id_chofer': idChofer,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/get-routes_J';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
 
  Future validarViajeActivo(idChofer) async {
    var parametros = {
      'id_chofer': idChofer,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/comprobar-viaje-actual';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  Future verEstadoUsuario(idUsuario) async {
    var parametros = {
      'id_usuario': idUsuario,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/get-routes_usuarios_J';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  Future validarViajeActivoUsuario(idUsuario) async {
    var parametros = {
      'idUsuario': idUsuario,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/comprobar-viaje-actual-usuario';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
 
  Future validarSiTieneParaRanking(idUsuario) async {
    var parametros = {
      'idUsuario': idUsuario,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/comprobar-tiene-para-ranking';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  Future listarRutaid(idRuta) async {
    var parametros = {
      'id': idRuta,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/buscarId';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  Future listarMisRutasPasajeros(idRuta) async {
    var parametros = {
      'id': idRuta,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/buscarRutasDePasajeroxIdRuta';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  Future listarRutaidSiNoExiste(idRuta) async {
    var parametros = {
      'id': idRuta,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/buscarIdSiNoExiste';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  Future obtenerRuta(origen,destino) async {
    try {
      String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=$origen&destination=$destino&language=es-419&key=${Config.googleMapsApiKey}';
        
      Response response = await Dio().get(url);
      
      if (response.data['status'] == 'OK') {
        return response.data;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future obtenerRutaConPuntosUsuarios(origen,destino,puntos) async {
    try {
      String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=$origen&destination=$destino&waypoints=optimize:true|$puntos&language=es-419&key=${Config.googleMapsApiKey}';
        
      Response response = await Dio().get(url);
      
      if (response.data['status'] == 'OK') {
        return response.data;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  Future recargarSaldo(int idChofer,double monto) async {
    var parametros = {
      'idChofer': idChofer,
      'monto':monto
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/pago/recargar-saldo';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  Future listarSaldo(int idChofer) async {
    var parametros = {
      'idChofer': idChofer
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/pago/listar-saldo';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  Future listarmovimientosSaldo(int idChofer) async {
    var parametros = {
      'idChofer': idChofer
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/pago/listar-movimientos-saldo';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future iniciarViaje(int idViaje,int asientos,String fecha) async {
    var parametros = {
      'idRuta': idViaje,
      'asientos': asientos ,
      'fecha': fecha,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/registro-viaje';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
 
  Future salirDeParaderoViaje(int idViaje) async {
    var parametros = {
      'idRuta': idViaje,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/viaje-salida-de-paradero';
      Response response = await Dio().post(url, data: parametros);
      return response.data['success'];
    } catch (e) {
      return false;
    }
  }
  
  Future terminarViaje(int idViaje) async {
    var parametros = {
      'idRuta': idViaje,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/viaje-terminar';
      Response response = await Dio().post(url, data: parametros);
      return response.data['success'];
    } catch (e) {
      return false;
    }
  }
  
  Future cancelarViaje(int idViaje) async {
    var parametros = {
      'idRuta': idViaje,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/cancelar-viaje';
      Response response = await Dio().post(url, data: parametros);
      return response.data['success'];
    } catch (e) {
      return false;
    }
  }

  Future listarSolicitudesxidRuta(idRuta) async {
    var parametros = {
      'idRuta': idRuta,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/buscarSolicitudes';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  Future listarMisAsientos(idServicio) async {
    var parametros = {
      'idServicio': idServicio,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/buscarMisAsientos';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  Future listarSolicitudesxidRutaUsuario(idRuta) async {
    // ES EL ID DEL USUARIO
    var parametros = {
      'idRuta': idRuta,
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/buscarSolicitudesUsuario';
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  Future crearSolicitudesxidRuta(idUsuario,idRuta,costo,salidaLat,salidaLong,destinoLat,destinoLong,
  recogermosControlerNombre,
  llegasControladorNombre,
  direccionInicial,
  direccionFinal,
  distritoInicial,
  distritoFinal,
  provinciaInicial,
  provinciaFinal,
  regionInicial,
  regionFinal,
  direccionExactaInicial,
  direccionExactaFinal
  ) async {
    var parametros = {
      'idUsuario': idUsuario,
      'idRuta': idRuta,
      'costo': costo,
      'salida_lat':salidaLat,
      'salida_long':salidaLong,
      'destino_lat':destinoLat,
      'destino_long':destinoLong,
      'recogermosControlerNombre':recogermosControlerNombre,
      'llegasControladorNombre':llegasControladorNombre,
      'direccionInicial':direccionInicial,
      'direccionFinal':direccionFinal,
      'distritoInicial':distritoInicial,
      'distritoFinal':distritoFinal,
      'provinciaInicial':provinciaInicial,
      'provinciaFinal':provinciaFinal,
      'regionInicial':regionInicial,
      'regionFinal':regionFinal,
      'direccionExactaInicial':direccionExactaInicial,
      'direccionExactaFinal':direccionExactaFinal
    };
    
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/crearSolicitudesxId';
      Response response = await Dio().post(url, data: parametros);
      
      if (response.data['success'] == true) {
        return true;
      } else {
        return false;
      }
      
    } catch (e) {
      return false;
    }
  }

  Future rutasRecomendadas(
    latiInicio,
    longiInicio,
    latiFin,
    longiFin
  ) async {
    var parametros = {
      'from_la': latiInicio,
      'from_lo': longiInicio,
      'to_la': latiFin,
      'to_lo': longiFin
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/lista_rutas_recomendadas';
      // String url = 'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/create_J?user_id=$idUsuario&name=$nombreRuta&cost=$precio&from_la=$latiInicio&to_la=$latiFin&from_lo=$longiInicio&to_lo=$longiFin';
      print('url');
      print(url);
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  Future rutasRecomendadasPosicion(
    idRuta
  ) async {
    var parametros = {
      'idRuta': idRuta
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/lista_rutas_recomendadas_seleccionada';
      
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  Future aceptarPasajero(
    idSolicitudViaje,
    costo,
    estado
  ) async {
    var parametros = {
      'idSolicitudServicioViaje': idSolicitudViaje,
      'costo':costo,
      'estado':estado
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/negociarConPasajero';
      
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
 
  
  Future validarSolicitud(idUsuario,idRuta) async {
    var parametros = {
      'idUsuario': idUsuario,
      'idRuta': idRuta
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/validarSolicitudes';
      
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'][0]['res'];
      } else {
        return 'E';
      }
    } catch (e) {
      return 'E';
    }
  }
  
  Future validarSolicitudesDeAsientos(idSolicitudViaje) async {
    var parametros = {
      'idSolicitudServicioViaje': idSolicitudViaje
    };

    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/validarSaldoConductor';
      
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'][0]['res'];
      } else {
        return 'E';
      }
    } catch (e) {
      return 'E';
    }
  }
  
  Future finalizarAsientoPasajero(idSolicitudViaje) async {
    var parametros = {
      'idSolicitudServicioViaje': idSolicitudViaje
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/terminarViajePasajero';
      
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'][0]['res'];
      } else {
        return 'E';
      }
    } catch (e) {
      return 'E';
    }
  }
  
  Future recogerAsientoPasajero(idSolicitudViaje) async {
    var parametros = {
      'idSolicitudServicioViaje': idSolicitudViaje
    };
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/routes/recogerViajePasajero';
      
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'][0]['res'];
      } else {
        return 'E';
      }
    } catch (e) {
      return 'E';
    }
  }

  Future calificarViaje(idServicio,idSoliServicio,idPasajero,origen,estrellas,califica) async {
    var parametros = {
      'idServicio': idServicio,
      'idSoliServicio': idSoliServicio,
      'passenger_id': idPasajero,
      'qualifying_person': origen,
      'stars': estrellas,
      'comment': '',
      'califica':califica
    };
    
    try {
      String url =
          'http://207.180.246.8:8080/ChasquiDB/public/api/interprovincial/driver/service/calificarViaje';
      
      Response response = await Dio().post(url, data: parametros);
      if (response.data['success'] == true) {
        return response.data['data'][0]['res'];
      } else {
        return 'E';
      }
    } catch (e) {
      return 'E';
    }
  }

}

