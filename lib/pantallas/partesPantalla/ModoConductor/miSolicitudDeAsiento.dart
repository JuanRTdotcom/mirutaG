import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miruta/lista_de_pantalla.dart';

class SolicitudDeAsiento extends StatefulWidget {
  final String idRuta;
  final String origen;

  const SolicitudDeAsiento({Key? key, required this.idRuta,required this.origen}) : super(key: key);

  @override
  State<SolicitudDeAsiento> createState() => _SolicitudDeAsientoState();
}

class _SolicitudDeAsientoState extends State<SolicitudDeAsiento> {
  bool cargandoSolicitudes = false;
  List misSolicitudes = [];


  Future<void> listarMisSolicitudes() async {
    setState(() {
      cargandoSolicitudes = true;
    });
    
    dynamic res = await Lib().listarSolicitudesxidRuta(widget.idRuta);
    if(mounted){
        setState(() {
          misSolicitudes = res;
          cargandoSolicitudes = false;
        });
    }
  }
  
  Future<void> listarMisSolicitudesUsuarios() async {
    setState(() {
      cargandoSolicitudes = true;
    });
    
    dynamic res = await Lib().listarSolicitudesxidRutaUsuario(widget.idRuta);
    if(mounted){
        setState(() {
          misSolicitudes = res;
          cargandoSolicitudes = false;
        });
    }
  }

  verCambiosSolicitudes()async{
     FirebaseFirestore.instance
          .collection("busquedas")
          .doc('cambio')
          .snapshots()
        .listen((event) async {
          if(widget.origen == "CONDUCTOR"){
          dynamic res = await Lib().listarSolicitudesxidRuta(widget.idRuta);
            if(mounted){
              setState(() {
                misSolicitudes = res;
              });
            }
          }else{
          dynamic res = await Lib().listarSolicitudesxidRutaUsuario(widget.idRuta);
            if(mounted){
              setState(() {
                misSolicitudes = res;
              });
            }
          }
        });

  }

  @override
  void initState() {
    super.initState();
    if(widget.origen == 'CONDUCTOR'){
      listarMisSolicitudes();
    }else{
      listarMisSolicitudesUsuarios();
    }
    verCambiosSolicitudes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
          title: const Text(
            'Solicitudes',
            style: TextStyle(fontSize: 12),
          ),
          centerTitle: true,
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
              ),
              onPressed: () => Navigator.of(context).pop(),
            );
          })),
      body: cargandoSolicitudes
          ? const Center(child: CupertinoActivityIndicator())
          : misSolicitudes.isEmpty
           ? Center(
             child: Opacity(
                opacity: .3,
               child: Column(
                 children: const [
                  SizedBox(height: 40,),
                   Icon(Icons.speaker_notes_off_outlined,size: 30,),
                  SizedBox(height: 10,),
                   Text('No tienes solicitudes',style: TextStyle(fontWeight: FontWeight.w600),)
                 ],
               ),
             ),
           )
           : ListView.builder(
              padding: const EdgeInsets.only(top: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: misSolicitudes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      right: 20, left: 20, top: 0, bottom: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 246, 244, 226)
                              .withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListTile(
                      minVerticalPadding: 12,
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute<void>(
                            builder: (BuildContext context) {
                          return NegociacionAsiento(
                            idRuta: misSolicitudes[index]['idRutaSv'],
                            origen: widget.origen=='PASAJERO'?'PASAJERO':'CONDUCTOR',
                            idSolicitudServicio: misSolicitudes[index]['Id'],
                            salida_lat: misSolicitudes[index]['vchLatInicial'],
                            salida_long: misSolicitudes[index]['vchLongInicial'],
                            destino_lat: misSolicitudes[index]['vchLatFinal'],
                            destino_long: misSolicitudes[index]['vchLongFinal'],
                            monto: misSolicitudes[index]['costoPropuesto'],
                            nombreUsuario: '${misSolicitudes[index]['vchNombres']} ${misSolicitudes[index]['vchApellidoP']}',
                          );
                        }));
                      },
                      title: Text(
                        (misSolicitudes[index]['iEstado']=='1' || misSolicitudes[index]['iEstado']=='7')
                        ? '${misSolicitudes[index]['vchNombres']} ${misSolicitudes[index]['vchApellidoP']}'
                        : '${misSolicitudes[index]['nombreChofer']} ${misSolicitudes[index]['apellidoPaternoChofer']}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        (misSolicitudes[index]['iEstado']=='6' || misSolicitudes[index]['iEstado']=='7')
                        ? 'Ha contraofertado S/ ${num.parse(misSolicitudes[index]['costoPropuesto']).toStringAsFixed(2)} por un asiento en el viaje ${misSolicitudes[index]['name']}'
                        : "Ha ofertado S/ ${num.parse(misSolicitudes[index]['costoPropuesto']).toStringAsFixed(2)} por un asiento en el viaje ${misSolicitudes[index]['name']}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: 
                              (misSolicitudes[index]['iEstado']=='7' || misSolicitudes[index]['iEstado']=='6')
                              ? const Color.fromARGB(255, 205, 223, 255)
                              : const Color.fromARGB(255, 255, 248, 225),
                              borderRadius: BorderRadius.circular(8)),
                          child: Icon(
                            (misSolicitudes[index]['iEstado']=='7' || misSolicitudes[index]['iEstado']=='6')
                            ? Icons.handshake_rounded
                            : Icons.airline_seat_recline_normal_rounded,
                            color: 
                            (misSolicitudes[index]['iEstado']=='7' || misSolicitudes[index]['iEstado']=='6')
                            ? Colors.blueAccent
                            : Colors.amber,
                          )),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
