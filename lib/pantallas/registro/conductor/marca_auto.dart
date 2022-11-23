import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miruta/lista_de_pantalla.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class MarcaAuto extends StatefulWidget {
  const MarcaAuto({Key? key}) : super(key: key);

  @override
  State<MarcaAuto> createState() => _MarcaAutoState();
}

class _MarcaAutoState extends State<MarcaAuto> {
  List misMarcas = [], misModelos = [];
  String idMarcaSeleccionada = '',
      idModeloSeleccionada = '',
      idColor = '',
      hastaFinal = 'Siguiente',
      fotoDni = '',
      fotoCara = '',
      vehiculoPlaca = '',
      fotoAntecedentes = '',
      licenciaFrontal = '';
  int _selectedIndex = 0,
      _selectedIndexModelo = 0,
      _selectedIndexColor = 0,
      currentStep = 0,
      sexo = 0,
      cagaSexo = 0;
  dynamic dniController = TextEditingController(),
      nombresController = TextEditingController(),
      paternoController = TextEditingController(),
      maternoController = TextEditingController(),
      placaController = TextEditingController(),
      emailController = TextEditingController(),
      fechaController = TextEditingController(),
      sexoController = TextEditingController(),
      numeroLicenciaController = TextEditingController(),
      imageFile,
      imageFileFotoVehiculoPlaca,
      imageFileFotoLicenciaFrontal,
      imageFileFotoLicenciaReverso,
      imageFileFotoDni,
      imageFileFotoAntecedentes;
  bool cargrRegistro = false, buscandoMarcas = true, buscaModelos = false;
  DateTime fecha = DateTime(1900, 01, 01);
  final picker = ImagePicker();

  List misColores = [
    {'nombre': 'Gris', 'color': Colors.grey},
    {'nombre': 'Plata', 'color': const Color(0xFFe3e4e5)},
    {'nombre': 'Blanco', 'color': Colors.white},
    {'nombre': 'Negro', 'color': Colors.black},
    {'nombre': 'Azul', 'color': Colors.blue},
    {'nombre': 'Azul claro', 'color': Colors.lightBlue},
    {'nombre': 'Verde', 'color': Colors.green},
    {'nombre': 'Rojo', 'color': Colors.red},
    {'nombre': 'Borgoña', 'color': const Color(0xFF6e3732)},
    {'nombre': 'Naranja', 'color': Colors.orange},
    {'nombre': 'Rosado', 'color': Colors.pink},
    {'nombre': 'Beige', 'color': const Color(0xFFf5f5dc)},
    {'nombre': 'Amarillo', 'color': Colors.yellow},
    {'nombre': 'Oro', 'color': const Color(0xFFffbf00)},
    {'nombre': 'Marrón', 'color': Colors.brown}
  ];

  void leerMarcas() async {
    dynamic marcas = await Lib().obtenerMarca();
    Map<String, dynamic> usuarioResponse = json.decode(marcas);
    if (mounted) {
      setState(() {
        misMarcas = usuarioResponse['data'];
        idMarcaSeleccionada =
            misMarcas.isEmpty ? '' : misMarcas[0]['iIdMarca'].toString();
        leerModelos(misMarcas[0]['iIdMarca'].toString());
        buscandoMarcas = false;
      });
    }
  }

  void leerModelos(String id) async {
    setState(() {
      buscaModelos = false;
    });
    dynamic modelos = await Lib().obtenerModelo(id);
    Map<String, dynamic> usuarioResponse = json.decode(modelos);
    if (mounted) {
      setState(() {
        misModelos = usuarioResponse['data'];
        idModeloSeleccionada =
            misModelos.isEmpty ? '' : misModelos[0]['iIdModelo'].toString();
        buscaModelos = true;
      });
    }
  }

  void cargarDataPersonal() async {
    const storage = FlutterSecureStorage();
    String? value = await storage.read(key: 'SESSION');
    Map<String, dynamic> usuarioResponse = json.decode(value ?? '');
    dynamic anioMiFechaNacimiento = usuarioResponse['fechaNacimiento'] == ''
        ? '1900'
        : usuarioResponse['fechaNacimiento'].toString().substring(0, 4);
    dynamic mesMiFechaNacimiento = usuarioResponse['fechaNacimiento'] == ''
        ? '01'
        : usuarioResponse['fechaNacimiento'].toString().substring(5, 7);
    dynamic diaMiFechaNacimiento = usuarioResponse['fechaNacimiento'] == ''
        ? '01'
        : usuarioResponse['fechaNacimiento'].toString().substring(8, 10);

    if (mounted) {
      setState(() {
        dniController.text = usuarioResponse['dni'] ?? '';
        nombresController.text = usuarioResponse['names'] ?? '';
        paternoController.text = usuarioResponse['last_name_father'] ?? '';
        maternoController.text = usuarioResponse['last_name_mother'] ?? '';
        sexo = int.parse(usuarioResponse['sexo'] ?? '1');
        sexo == 1
            ? sexoController.text = 'Masculino'
            : sexoController.text = 'Femenino';
        fecha = DateTime(int.parse(anioMiFechaNacimiento),
            int.parse(mesMiFechaNacimiento), int.parse(diaMiFechaNacimiento));
        fechaController.text =
            '${fecha.year}/${fecha.month.toString().length == 1 ? '0${fecha.month}' : fecha.month}/${fecha.day.toString().length == 1 ? '0${fecha.day}' : fecha.day}';
        idColor = misColores[0]['nombre'];
      });
    }
  }

  @override
  void initState() {
    leerMarcas();
    cargarDataPersonal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FocusScopeNode focus = FocusScope.of(context);
    return GestureDetector(
      onTap: () {
        if (!focus.hasPrimaryFocus && focus.hasFocus) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                      onSurface: const Color.fromARGB(255, 167, 167, 167),
                      primary: const Color.fromRGBO(253, 189, 16, 1))),
              child: Stepper(
                elevation: 0,
                physics: const BouncingScrollPhysics(),
                currentStep: currentStep,
                onStepTapped: (index) async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  switch (index) {
                    case 0:
                      setState(() => currentStep = 0);
                      break;
                    case 1:
                      if (idMarcaSeleccionada == '') {
                        setState(() => currentStep = 0);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar una marca antes de continuar",
                          ),
                        );
                      } else {
                        setState(() => currentStep = index);
                      }
                      break;
                    case 2:
                      if (idMarcaSeleccionada == '') {
                        setState(() => currentStep = 0);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar una marca antes de continuar",
                          ),
                        );
                      } else if (idModeloSeleccionada == '') {
                        setState(() => currentStep = 1);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar un modelo antes de continuar",
                          ),
                        );
                      } else {
                        setState(() => currentStep = index);
                      }
                      break;
                    case 3:
                      if (idMarcaSeleccionada == '') {
                        setState(() => currentStep = 0);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar una marca antes de continuar",
                          ),
                        );
                      } else if (idModeloSeleccionada == '') {
                        setState(() => currentStep = 1);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar un modelo antes de continuar",
                          ),
                        );
                      } else if (idColor == '') {
                        setState(() => currentStep = 2);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar un color para tu vehículo",
                          ),
                        );
                      } else {
                        setState(() => currentStep = index);
                      }
                      break;
                    case 4:
                      if (idMarcaSeleccionada == '') {
                        setState(() => currentStep = 0);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar una marca antes de continuar",
                          ),
                        );
                      } else if (idModeloSeleccionada == '') {
                        setState(() => currentStep = 1);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar un modelo antes de continuar",
                          ),
                        );
                      } else if (idColor == '') {
                        setState(() => currentStep = 2);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar un color para tu vehículo",
                          ),
                        );
                      } else if (placaController.text == '' ||
                          placaController.text.length != 6) {
                        setState(() => currentStep = 3);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message: "Debes ingresa un número de placa válido",
                          ),
                        );
                      } else {
                        setState(() => currentStep = index);
                      }
                      break;
                    case 5:
                      if (idMarcaSeleccionada == '') {
                        setState(() => currentStep = 0);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar una marca antes de continuar",
                          ),
                        );
                      } else if (idModeloSeleccionada == '') {
                        setState(() => currentStep = 1);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar un modelo antes de continuar",
                          ),
                        );
                      } else if (idColor == '') {
                        setState(() => currentStep = 2);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar un color para tu vehículo",
                          ),
                        );
                      } else if (placaController.text == '' ||
                          placaController.text.length != 6) {
                        setState(() => currentStep = 3);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message: "Debes ingresa un número de placa válido",
                          ),
                        );
                      } else if (dniController.text == '' ||
                          nombresController.text == '' ||
                          paternoController.text == '' ||
                          maternoController.text == '' ||
                          sexoController.text == '' ||
                          emailController.text == '' ||
                          imageFile == null) {
                        setState(() => currentStep = 4);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message: "Debes completar tu información personal",
                          ),
                        );
                      } else {
                        setState(() => currentStep = index);
                      }
                      break;
                    case 6:
                      if (idMarcaSeleccionada == '') {
                        setState(() => currentStep = 0);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar una marca antes de continuar",
                          ),
                        );
                      } else if (idModeloSeleccionada == '') {
                        setState(() => currentStep = 1);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar un modelo antes de continuar",
                          ),
                        );
                      } else if (idColor == '') {
                        setState(() => currentStep = 2);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar un color para tu vehículo",
                          ),
                        );
                      } else if (placaController.text == '' ||
                          placaController.text.length != 6) {
                        setState(() => currentStep = 3);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message: "Debes ingresa un número de placa válido",
                          ),
                        );
                      } else if (dniController.text == '' ||
                          nombresController.text == '' ||
                          paternoController.text == '' ||
                          maternoController.text == '' ||
                          sexoController.text == '' ||
                          emailController.text == '' ||
                          imageFile == null) {
                        setState(() => currentStep = 4);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message: "Debes completar tu información personal",
                          ),
                        );
                      } else if (imageFileFotoVehiculoPlaca == null) {
                        setState(() => currentStep = 5);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes adjuntar la foto de tu vehículo con su placa",
                          ),
                        );
                      } else {
                        setState(() => currentStep = index);
                      }
                      break;
                    case 7:
                      if (idMarcaSeleccionada == '') {
                        setState(() => currentStep = 0);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar una marca antes de continuar",
                          ),
                        );
                      } else if (idModeloSeleccionada == '') {
                        setState(() => currentStep = 1);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar un modelo antes de continuar",
                          ),
                        );
                      } else if (idColor == '') {
                        setState(() => currentStep = 2);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes seleccionar un color para tu vehículo",
                          ),
                        );
                      } else if (placaController.text == '' ||
                          placaController.text.length != 6) {
                        setState(() => currentStep = 3);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message: "Debes ingresa un número de placa válido",
                          ),
                        );
                      } else if (dniController.text == '' ||
                          nombresController.text == '' ||
                          paternoController.text == '' ||
                          maternoController.text == '' ||
                          sexoController.text == '' ||
                          emailController.text == '' ||
                          imageFile == null) {
                        setState(() => currentStep = 4);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message: "Debes completar tu información personal",
                          ),
                        );
                      } else if (imageFileFotoVehiculoPlaca == null) {
                        setState(() => currentStep = 5);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message:
                                "Debes adjuntar la foto de tu vehículo con su placa",
                          ),
                        );
                      } else if (imageFileFotoLicenciaFrontal == null ||
                          imageFileFotoLicenciaReverso == null ||
                          imageFileFotoDni == null ||
                          imageFileFotoAntecedentes == null ||
                          numeroLicenciaController.text == '') {
                        setState(() => currentStep = 6);
                        showTopSnackBar(
                          context,
                          const CustomSnackBar.error(
                            textStyle: TextStyle(fontSize: 14,color: Colors.white),
                            message: "Debes completar gestión de documentos",
                          ),
                        );
                      } else {
                        setState(() => currentStep = index);
                      }
                      break;
                  }
                },
                controlsBuilder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      currentStep == 0 ||
                              currentStep == 1 ||
                              currentStep == 2 ||
                              currentStep == 3 ||
                              currentStep == 4 ||
                              currentStep == 5 ||
                              currentStep == 6 ||
                              currentStep == 7 
                          ? const SizedBox(
                              width: 0,
                              height: 0,
                            )
                          : OutlinedButton(
                              onPressed: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                if (currentStep != 0) {
                                  setState(() => currentStep--);
                                }
                              },
                              style: ButtonStyle(
                                // backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(253, 189, 16, 1)),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: Text(
                                  'Anterior',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Clan',
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 121, 121, 121),
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(
                        width: 10,
                      ),
                      currentStep == 0 ||
                              currentStep == 1 ||
                              currentStep == 2 ||
                              currentStep == 3 ||
                              currentStep == 4 ||
                              currentStep == 5 ||
                              currentStep == 6
                          ? const SizedBox(
                              width: 0,
                              height: 0,
                            )
                          : OutlinedButton(
                              onPressed: () async {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                switch (currentStep) {
                                  case 7:
                                    showCupertinoModalPopup(
                                        context: context,
                                        builder: (_) => Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              child:
                                                  const CupertinoActivityIndicator(
                                                radius: 15,
                                              ),
                                            ));
                                    const storage = FlutterSecureStorage();
                                    String? value =
                                        await storage.read(key: 'SESSION');
                                    Map<String, dynamic> usuarioResponse =
                                        json.decode(value ?? '');

                                    String fotoDni = await Lib()
                                        .obtenerBase64(imageFileFotoDni);
                                    String fotoCara =
                                        await Lib().obtenerBase64(imageFile);
                                    String vehiculoPlaca = await Lib()
                                        .obtenerBase64(
                                            imageFileFotoVehiculoPlaca);
                                    String fotoAntecedentes = await Lib()
                                        .obtenerBase64(
                                            imageFileFotoAntecedentes);
                                    String licenciaFrontal = await Lib()
                                        .obtenerBase64(
                                            imageFileFotoLicenciaFrontal);

                                    var miRegistro = await Lib()
                                        .registrarChofer(
                                            usuarioResponse['dni'],
                                            usuarioResponse['names'],
                                            usuarioResponse['last_name_father'],
                                            usuarioResponse['last_name_mother'],
                                            DateTimeExtension
                                                    .parseDateEnglishV2(fecha)
                                                .toString(),
                                            sexo.toString(),
                                            usuarioResponse['direccion'],
                                            usuarioResponse['referencia'],
                                            usuarioResponse['cellphone'],
                                            usuarioResponse['cellphone'],
                                            emailController.text,
                                            usuarioResponse['password'],
                                            '',
                                            idMarcaSeleccionada,
                                            '',
                                            '',
                                            '123', // token
                                            placaController.text,
                                            idModeloSeleccionada,
                                            '4',
                                            '2018',
                                            '1',
                                            fotoDni,
                                            fotoCara,
                                            vehiculoPlaca,
                                            fotoAntecedentes,
                                            licenciaFrontal);
                                    await Lib().iniciarSesion(
                                        usuarioResponse['cellphone']);
                                    if (miRegistro) {
                                      Navigator.pop(context);
                                      showTopSnackBar(
                                        context,
                                        const CustomSnackBar.success(
                                          message:
                                              "Solicitud enviada. Nos pondremos en contacto contigo.",
                                        ),
                                      );
                                      Navigator.of(context).pushAndRemoveUntil(
                                          CupertinoPageRoute<void>(
                                              builder: (BuildContext context) {
                                        return const Principal(
                                            logueadoApp: true);
                                      }), (Route<dynamic> route) => false);
                                    } else {
                                      Navigator.pop(context);
                                      showTopSnackBar(
                                        context,
                                        const CustomSnackBar.error(
                                          message:
                                              "Error del servidor. Inténtalo nuevamente.",
                                        ),
                                      );
                                    }

                                    break;
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromRGBO(253, 189, 16, 1)),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0))),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: Text(
                                  currentStep == 7 ? 'Finalizar' : hastaFinal,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Clan',
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 12, 12, 12),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  );
                },
                steps: [
                  Step(
                      subtitle: const Text('Selecciona la marca de tu vehículo',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w500)),
                      isActive: currentStep >= 0,
                      title: Text('Marca (${misMarcas.length})',
                          style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w600)),
                      content: AnimatedContainer(
                        height: buscandoMarcas == true
                            ? 160
                            : 60 * misMarcas.length / 1,
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height / 1.75),
                        duration: const Duration(milliseconds: 200),
                        child: buscandoMarcas == true
                            ? const CargandoLista()
                            : ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(
                                          height: 1,
                                        ),
                                physics: const BouncingScrollPhysics(),
                                itemCount: misMarcas.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    dense: true,
                                    leading: Image.asset(
                                        'assets/images/png/default/mazda.png',
                                        width: 25,
                                        fit: BoxFit.contain),
                                    trailing: index == _selectedIndex
                                        ? Container(
                                            child: buscaModelos == true
                                                ? FadeIn(
                                                    duration: const Duration(
                                                        milliseconds: 150),
                                                    child: const Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: Color.fromRGBO(
                                                          253, 189, 16, 1),
                                                    ))
                                                : const CupertinoActivityIndicator(),
                                          )
                                        : const Text(''),
                                    selected: index == _selectedIndex,
                                    selectedColor:
                                        const Color.fromRGBO(21, 21, 21, 1),
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = index;

                                        idMarcaSeleccionada = misMarcas[index]
                                                ['iIdMarca']
                                            .toString();
                                      });
                                      leerModelos(misMarcas[index]['iIdMarca']
                                          .toString());
                                    },
                                    title: Text(
                                      misMarcas[index]['vchMarca'],
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Clan',
                                          fontWeight: FontWeight.w500),
                                    ),
                                  );
                                }),
                      )),
                  Step(
                      subtitle: const Text(
                          'Selecciona el modelo de tu vehículo',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w500)),
                      isActive: currentStep >= 1,
                      title: Text('Modelo (${misModelos.length})',
                          style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w600)),
                      content: Container(
                        height: 60 * misModelos.length / 1,
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height / 1.75),
                        child: ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(
                                      height: 1,
                                    ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: misModelos.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                dense: true,
                                trailing: index == _selectedIndexModelo
                                    ? FadeIn(
                                        child: const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color.fromRGBO(253, 189, 16, 1),
                                      ))
                                    : const Text(''),
                                selected: index == _selectedIndexModelo,
                                selectedColor:
                                    const Color.fromRGBO(21, 21, 21, 1),
                                onTap: () {
                                  setState(() {
                                    _selectedIndexModelo = index;
                                    idModeloSeleccionada = misModelos[index]
                                            ['iIdModelo']
                                        .toString();
                                  });
                                },
                                title: Text(misModelos[index]['vchModelo'],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Clan',
                                        fontWeight: FontWeight.w500)),
                              );
                            }),
                      )),
                  Step(
                      subtitle: const Text('Selecciona el color de tu vehículo',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w500)),
                      isActive: currentStep >= 2,
                      title: const Text('Color',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w600)),
                      content: Padding(
                        padding: const EdgeInsets.only(bottom: 20, top: 10),
                        child: Container(
                          height: 60 * misColores.length / 1,
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height / 1.75),
                          child: ListView.separated(
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(
                                        height: 1,
                                      ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: misColores.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  dense: true,
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      color: misColores[index]['color'],
                                    ),
                                  ),
                                  trailing: index == _selectedIndexColor
                                      ? FadeIn(
                                          child: const Icon(
                                          Icons.check_circle_rounded,
                                          color:
                                              Color.fromRGBO(253, 189, 16, 1),
                                        ))
                                      : const Text(''),
                                  selected: index == _selectedIndexColor,
                                  selectedColor:
                                      const Color.fromRGBO(21, 21, 21, 1),
                                  onTap: () {
                                    setState(() {
                                      _selectedIndexColor = index;
                                      idColor = misColores[index]['nombre'];
                                    });
                                  },
                                  title: Text(
                                    misColores[index]['nombre'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }),
                        ),
                      )),
                  Step(
                      subtitle: const Text('Número de placa de tu vehículo',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w500)),
                      isActive: currentStep >= 3,
                      title: const Text('Placa',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w600)),
                      content: Column(
                        children: [
                          Container(
                            height: 150,
                            margin: const EdgeInsets.only(bottom: 10, top: 10),
                            // height: MediaQuery.of(context).size.height - 250,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                color: const Color.fromRGBO(21, 21, 21, 1),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        'Número de placa de tu vehículo',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextFormField(
                                          controller: placaController,
                                          inputFormatters: [
                                            PlacaInputFormatter()
                                          ],
                                          keyboardType: TextInputType.text,
                                          onChanged: (value) {
                                            // setState(() {
                                            //   placa = value;
                                            // });
                                          },
                                          style: const TextStyle(
                                              color: Color.fromRGBO(
                                                  253, 189, 16, 1)),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 15.0, top: 15.0),
                                            hintText: 'ABC123',
                                            hintStyle: const TextStyle(
                                                color: Color.fromARGB(
                                                    119, 255, 255, 255),
                                                fontSize: 14),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              'Tu número de placa solo es necesario para que el pasajero identifique tu vehículo.',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 184, 184, 184),
                                  fontSize: 11),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      )),
                  Step(
                      subtitle: const Text('Completa tu información personal',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w500)),
                      isActive: currentStep >= 4,
                      title: const Text('Información personal',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w600)),
                      content: SizedBox(
                        // height: MediaQuery.of(context).size.height - 250,
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 0,
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: imageFile != null
                                          ? Colors.transparent
                                          : const Color.fromARGB(
                                              255, 236, 236, 236),
                                      child: imageFile != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(100)),
                                              child: SizedBox(
                                                  width: 120,
                                                  height: 120,
                                                  child: Image.file(imageFile,
                                                      fit: BoxFit.cover)))
                                          : const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Añadir una nueva foto'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: ListBody(
                                                        children: <Widget>[
                                                          GestureDetector(
                                                            child: const Text(
                                                                'Tomar una foto'),
                                                            onTap: () async {
                                                              var picture = await picker
                                                                  .pickImage(
                                                                      source: ImageSource
                                                                          .camera);
                                                              if (picture !=
                                                                  null) {
                                                                imageFile =
                                                                    File(picture
                                                                        .path);
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {});
                                                              }
                                                            },
                                                          ),
                                                          const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          8.0)),
                                                          GestureDetector(
                                                            child: const Text(
                                                                'Seleccionar una foto'),
                                                            onTap: () async {
                                                              final picker =
                                                                  ImagePicker();
                                                              var picture = await picker
                                                                  .pickImage(
                                                                      source: ImageSource
                                                                          .gallery);
                                                              if (picture !=
                                                                  null) {
                                                                imageFile =
                                                                    File(picture
                                                                        .path);
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {});
                                                              }
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                          },
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                color: Color.fromRGBO(
                                                    253, 189, 16, 1),
                                              ),
                                              width: 30,
                                              height: 30,
                                              child: const Icon(
                                                Icons.edit,
                                                size: 20,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                              )),
                                        ),
                                      ))
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Documento de identidad',
                                  style: TextStyle(fontSize: 10),
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color.fromRGBO(192, 192, 192, 1),
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: TextFormField(
                                readOnly: true,
                                controller: dniController,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    fillColor: Colors.white,
                                    hintText: "Doc de Identidad",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromRGBO(192, 192, 192, 1))),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Nombres',
                                  style: TextStyle(fontSize: 10),
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color.fromRGBO(192, 192, 192, 1),
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: TextFormField(
                                readOnly: true,
                                controller: nombresController,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    fillColor: Colors.white,
                                    hintText: "Nombres",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromRGBO(192, 192, 192, 1))),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Apellido paterno',
                                  style: TextStyle(fontSize: 10),
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color.fromRGBO(192, 192, 192, 1),
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: TextFormField(
                                readOnly: true,
                                controller: paternoController,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    fillColor: Colors.white,
                                    hintText: "Primer Apellido",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromRGBO(192, 192, 192, 1))),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Apellido materno',
                                  style: TextStyle(fontSize: 10),
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color.fromRGBO(192, 192, 192, 1),
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: TextFormField(
                                readOnly: true,
                                controller: maternoController,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    fillColor: Colors.white,
                                    hintText: "Segundo Apellido",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromRGBO(192, 192, 192, 1))),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Sexo',
                                  style: TextStyle(fontSize: 10),
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color.fromRGBO(192, 192, 192, 1),
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: TextFormField(
                                readOnly: true,
                                controller: sexoController,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    fillColor: Colors.white,
                                    hintText: "Doc de Identidad",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromRGBO(192, 192, 192, 1))),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Correo electrónico',
                                  style: TextStyle(fontSize: 10),
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color.fromRGBO(192, 192, 192, 1),
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: TextFormField(
                                controller: emailController,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    fillColor: Colors.white,
                                    hintText: "Correo electrónico",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromRGBO(192, 192, 192, 1))),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Fecha de nacimiento',
                                  style: TextStyle(fontSize: 10),
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color.fromRGBO(192, 192, 192, 1),
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: TextFormField(
                                // enabled: false,
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDateTime =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100),
                                    // locale: const Locale('es','ES'),
                                  );
                                  if (pickedDateTime == null) return;
                                  setState(() {
                                    fecha = pickedDateTime;
                                    fechaController.text =
                                        '${fecha.year}/${fecha.month.toString().length == 1 ? '0${fecha.month}' : fecha.month}/${fecha.day.toString().length == 1 ? '0${fecha.day}' : fecha.day}';
                                  });
                                },
                                controller: fechaController,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    fillColor: Colors.white,
                                    hintText: "Fecha de nacimiento",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromRGBO(192, 192, 192, 1))),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      )),
                  Step(
                      subtitle: const Text('Foto de tu vehículo con su placa',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w500)),
                      isActive: currentStep >= 5,
                      title: const Text('Vehículo y placa',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w600)),
                      content: SizedBox(
                        child: Column(
                          children: [
                            Container(
                              height: 150,
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 10),
                              // height: MediaQuery.of(context).size.height - 250,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Añadir una nueva foto'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        child: const Text(
                                                            'Tomar una foto'),
                                                        onTap: () async {
                                                          var picture = await picker
                                                              .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .camera);
                                                          if (picture != null) {
                                                            imageFileFotoVehiculoPlaca =
                                                                File(picture
                                                                    .path);
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {});
                                                          }
                                                        },
                                                      ),
                                                      const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0)),
                                                      GestureDetector(
                                                        child: const Text(
                                                            'Seleccionar una foto'),
                                                        onTap: () async {
                                                          final picker =
                                                              ImagePicker();
                                                          var picture = await picker
                                                              .pickImage(
                                                                  source: ImageSource
                                                                      .gallery);
                                                          if (picture != null) {
                                                            imageFileFotoVehiculoPlaca =
                                                                File(picture
                                                                    .path);
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {});
                                                          }
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          color: const Color.fromRGBO(
                                              21, 21, 21, 1),
                                          child: imageFileFotoVehiculoPlaca !=
                                                  null
                                              ? ClipRRect(
                                                  child: Image.file(
                                                      imageFileFotoVehiculoPlaca,
                                                      fit: BoxFit.cover))
                                              : const Icon(
                                                  Icons.photo_camera_rounded,
                                                  color: Color.fromARGB(
                                                      166, 253, 190, 16),
                                                  size: 50),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                'Ingresa una fotografía de tu vehículo con la placa visible, para poder validar tu automóvil.',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 184, 184, 184),
                                    fontSize: 11),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      )),
                  Step(
                      subtitle: const Text('Fotografías de tus documentos',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w500)),
                      isActive: currentStep >= 6,
                      title: const Text('Gestión de documentos',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w600)),
                      content: SizedBox(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Licencia de conducir',
                                  style: TextStyle(fontSize: 10),
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color.fromRGBO(192, 192, 192, 1),
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: TextFormField(
                                controller: numeroLicenciaController,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    fillColor: Colors.white,
                                    hintText: "D12345678",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromRGBO(192, 192, 192, 1))),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                'Ingresa una fotografía FRONTAL de tu licencia de conducir',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 184, 184, 184),
                                    fontSize: 11),
                              ),
                            ),
                            Container(
                              height: 150,
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 10),
                              // height: MediaQuery.of(context).size.height - 250,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Añadir una nueva foto'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        child: const Text(
                                                            'Tomar una foto'),
                                                        onTap: () async {
                                                          var picture = await picker
                                                              .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .camera);
                                                          if (picture != null) {
                                                            imageFileFotoLicenciaFrontal =
                                                                File(picture
                                                                    .path);
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {});
                                                          }
                                                        },
                                                      ),
                                                      const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0)),
                                                      GestureDetector(
                                                        child: const Text(
                                                            'Seleccionar una foto'),
                                                        onTap: () async {
                                                          final picker =
                                                              ImagePicker();
                                                          var picture = await picker
                                                              .pickImage(
                                                                  source: ImageSource
                                                                      .gallery);
                                                          if (picture != null) {
                                                            imageFileFotoLicenciaFrontal =
                                                                File(picture
                                                                    .path);
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {});
                                                          }
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          color: const Color.fromRGBO(
                                              21, 21, 21, 1),
                                          child: imageFileFotoLicenciaFrontal !=
                                                  null
                                              ? ClipRRect(
                                                  child: Image.file(
                                                      imageFileFotoLicenciaFrontal,
                                                      fit: BoxFit.cover))
                                              : const Icon(
                                                  Icons.photo_camera_rounded,
                                                  color: Color.fromARGB(
                                                      166, 253, 190, 16),
                                                  size: 50),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                'Ingresa una fotografía del REVERSO de tu licencia de conducir',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 184, 184, 184),
                                    fontSize: 11),
                              ),
                            ),
                            Container(
                              height: 150,
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 10),
                              // height: MediaQuery.of(context).size.height - 250,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Añadir una nueva foto'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        child: const Text(
                                                            'Tomar una foto'),
                                                        onTap: () async {
                                                          var picture = await picker
                                                              .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .camera);
                                                          if (picture != null) {
                                                            imageFileFotoLicenciaReverso =
                                                                File(picture
                                                                    .path);
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {});
                                                          }
                                                        },
                                                      ),
                                                      const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0)),
                                                      GestureDetector(
                                                        child: const Text(
                                                            'Seleccionar una foto'),
                                                        onTap: () async {
                                                          final picker =
                                                              ImagePicker();
                                                          var picture = await picker
                                                              .pickImage(
                                                                  source: ImageSource
                                                                      .gallery);
                                                          if (picture != null) {
                                                            imageFileFotoLicenciaReverso =
                                                                File(picture
                                                                    .path);
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {});
                                                          }
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          color: const Color.fromRGBO(
                                              21, 21, 21, 1),
                                          child: imageFileFotoLicenciaReverso !=
                                                  null
                                              ? ClipRRect(
                                                  child: Image.file(
                                                      imageFileFotoLicenciaReverso,
                                                      fit: BoxFit.cover))
                                              : const Icon(
                                                  Icons.photo_camera_rounded,
                                                  color: Color.fromARGB(
                                                      166, 253, 190, 16),
                                                  size: 50),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                'Ingresa una fotografía de tu documento de identidad parte frontal',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 184, 184, 184),
                                    fontSize: 11),
                              ),
                            ),
                            Container(
                              height: 150,
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 10),
                              // height: MediaQuery.of(context).size.height - 250,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Añadir una nueva foto'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        child: const Text(
                                                            'Tomar una foto'),
                                                        onTap: () async {
                                                          var picture = await picker
                                                              .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .camera);
                                                          if (picture != null) {
                                                            imageFileFotoDni =
                                                                File(picture
                                                                    .path);
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {});
                                                          }
                                                        },
                                                      ),
                                                      const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0)),
                                                      GestureDetector(
                                                        child: const Text(
                                                            'Seleccionar una foto'),
                                                        onTap: () async {
                                                          final picker =
                                                              ImagePicker();
                                                          var picture = await picker
                                                              .pickImage(
                                                                  source: ImageSource
                                                                      .gallery);
                                                          if (picture != null) {
                                                            imageFileFotoDni =
                                                                File(picture
                                                                    .path);
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {});
                                                          }
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          color: const Color.fromRGBO(
                                              21, 21, 21, 1),
                                          child: imageFileFotoDni != null
                                              ? ClipRRect(
                                                  child: Image.file(
                                                      imageFileFotoDni,
                                                      fit: BoxFit.cover))
                                              : const Icon(
                                                  Icons.photo_camera_rounded,
                                                  color: Color.fromARGB(
                                                      166, 253, 190, 16),
                                                  size: 50),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Text.rich(TextSpan(
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 184, 184, 184),
                                        fontSize: 11),
                                    children: [
                                      TextSpan(
                                          text:
                                              "Ingresa una fotografía de cualquiera de estos documentos:\n"),
                                      TextSpan(
                                          text:
                                              "- Tarjeta de taxista (Fotocheck)\n"),
                                      TextSpan(
                                          text:
                                              "- Cuenta de otra aplicación de taxi\n"),
                                      TextSpan(
                                          text:
                                              "- Carta de antecedentes no penales"),
                                    ]))
                                // Text(
                                //   'Ingresa una fotografía de cualquiera de estos documentos: TARJETA DE TAXISTA (FOTOCHECK), FOTO DE LA CUENTA DE OTRA APLICACIÓN DE TAXI, CARTA DE ANTECEDENTES NO PENALES',
                                //   style: TextStyle(
                                //       color: Color.fromARGB(255, 184, 184, 184),
                                //       fontSize: 11),
                                // ),
                                ),
                            Container(
                              height: 150,
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 10),
                              // height: MediaQuery.of(context).size.height - 250,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Añadir una nueva foto'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        child: const Text(
                                                            'Tomar una foto'),
                                                        onTap: () async {
                                                          var picture = await picker
                                                              .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .camera);
                                                          if (picture != null) {
                                                            imageFileFotoAntecedentes =
                                                                File(picture
                                                                    .path);
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {});
                                                          }
                                                        },
                                                      ),
                                                      const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0)),
                                                      GestureDetector(
                                                        child: const Text(
                                                            'Seleccionar una foto'),
                                                        onTap: () async {
                                                          final picker =
                                                              ImagePicker();
                                                          var picture = await picker
                                                              .pickImage(
                                                                  source: ImageSource
                                                                      .gallery);
                                                          if (picture != null) {
                                                            imageFileFotoAntecedentes =
                                                                File(picture
                                                                    .path);
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {});
                                                          }
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          color: const Color.fromRGBO(
                                              21, 21, 21, 1),
                                          child: imageFileFotoAntecedentes !=
                                                  null
                                              ? ClipRRect(
                                                  child: Image.file(
                                                      imageFileFotoAntecedentes,
                                                      fit: BoxFit.cover))
                                              : const Icon(
                                                  Icons.photo_camera_rounded,
                                                  color: Color.fromARGB(
                                                      166, 253, 190, 16),
                                                  size: 50),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      )),
                  Step(
                      subtitle: const Text('Paso final del registro',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w500)),
                      isActive: currentStep >= 7,
                      title: const Text('Finalizar registro',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Clan',
                              fontWeight: FontWeight.w600)),
                      content: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Image.asset('assets/images/png/default/bordetop.png',
                              // width: MediaQuery.of(context).size.width * 0.2,
                              fit: BoxFit.contain),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: Container(
                              color: const Color.fromRGBO(253, 198, 45, 1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 25),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                        'assets/images/png/login/final.png',
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        fit: BoxFit.contain),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text('Finaliza tu registro',
                                        style: TextStyle(
                                            fontFamily: 'Clan',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20)),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Text(
                                          "Tu solicitud será puesta en evaluación hasta que un administrador revise tu información en un plazo máximo de dos días. Gracias por la espera.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Clan',
                                              color: Color.fromARGB(
                                                  255, 62, 62, 62),
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Image.asset('assets/images/png/default/borde.png',
                              // width: MediaQuery.of(context).size.width * 0.2,
                              fit: BoxFit.contain),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CargandoLista extends StatelessWidget {
  const CargandoLista({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: Shimmer.fromColors(
                  child: Container(
                    width: 35,
                    height: 35,
                    color: Colors.grey,
                  ),
                  baseColor: Colors.black.withOpacity(0.04),
                  highlightColor: Colors.black.withOpacity(0.08)),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: Shimmer.fromColors(
                    child: Container(
                      width: 150,
                      height: 18,
                      color: Colors.grey,
                    ),
                    baseColor: Colors.black.withOpacity(0.04),
                    highlightColor: Colors.black.withOpacity(0.08)),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(height: 1),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Shimmer.fromColors(
                  child: Container(
                    width: 35,
                    height: 35,
                    color: Colors.grey,
                  ),
                  baseColor: Colors.black.withOpacity(0.04),
                  highlightColor: Colors.black.withOpacity(0.08)),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: Shimmer.fromColors(
                    child: Container(
                      width: 150,
                      height: 18,
                      color: Colors.grey,
                    ),
                    baseColor: Colors.black.withOpacity(0.04),
                    highlightColor: Colors.black.withOpacity(0.08)),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(height: 1),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Shimmer.fromColors(
                  child: Container(
                    width: 35,
                    height: 35,
                    color: Colors.grey,
                  ),
                  baseColor: Colors.black.withOpacity(0.04),
                  highlightColor: Colors.black.withOpacity(0.08)),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: Shimmer.fromColors(
                    child: Container(
                      width: 150,
                      height: 18,
                      color: Colors.grey,
                    ),
                    baseColor: Colors.black.withOpacity(0.04),
                    highlightColor: Colors.black.withOpacity(0.08)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PlacaInputFormatter extends TextInputFormatter {
  final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = '';
    int newLength = newValue.text.length;
    if (newLength == 0) {
      newText = newValue.text.toUpperCase();
    } else if (newLength < 4) {
      if (validCharacters.hasMatch(newValue.text) ||
          int.tryParse(newValue.text) != null) {
        newText = newValue.text.toUpperCase();
      } else {
        newText = oldValue.text.toUpperCase();
      }
    } else if (newLength > 3 && newLength < 7) {
      final partial = newValue.text.substring(3, newValue.text.length);
      if (int.tryParse(partial) != null) {
        newText = newValue.text.toUpperCase();
      } else {
        newText = oldValue.text.toUpperCase();
      }
    } else {
      newText = oldValue.text.toUpperCase();
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
