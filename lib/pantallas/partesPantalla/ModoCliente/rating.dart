import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:miruta/lista_de_pantalla.dart';

class Rating_pasajero extends StatefulWidget {
  final dynamic idServicio;
  final dynamic idUsuario;
  final dynamic idSoliServicio;

  const Rating_pasajero(
      {Key? key, required this.idServicio, required this.idUsuario, required this.idSoliServicio})
      : super(key: key);
  @override
  State<Rating_pasajero> createState() => _Rating_pasajeroState();
}

class _Rating_pasajeroState extends State<Rating_pasajero> {
  double estrellas = 3.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Llegaste a tu destino!',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            'Califica tu viaje',
            style:
                TextStyle(color: Colors.black26, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 35,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: RatingBar.builder(
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_rate_rounded,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  if (mounted) {
                    setState(() {
                      estrellas = rating;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: const Color.fromARGB(255, 226, 226, 226),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: MaterialButton(
                  // color: Color.fromARGB(255, 0, 0, 0),
                  // minWidth: MediaQuery.of(context).size.width * 0.8,
                  // height: 60,
                  onPressed: ()  async {
                    var calificacion = await Lib().calificarViaje(
                        widget.idServicio,widget.idSoliServicio, widget.idUsuario, 'PASAJERO', estrellas,0);
                        
                    Navigator.of(context).pushAndRemoveUntil(
                        CupertinoPageRoute<void>(
                            builder: (BuildContext context) {
                      return const Menu();
                    }), (Route<dynamic> route) => false);
                  },
                  elevation: 0,
                  splashColor: Colors.transparent,
                  child: const Text('Omitir',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 35, 35, 35))),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Material(
                color: const Color.fromRGBO(34, 34, 34, 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: MaterialButton(
                  // color: Color.fromARGB(255, 0, 0, 0),
                  // minWidth: MediaQuery.of(context).size.width * 0.8,
                  // height: 60,
                  onPressed: () async{

                    await Lib().calificarViaje(
                        widget.idServicio,widget.idSoliServicio, widget.idUsuario, 'PASAJERO', estrellas,1);
                    showTopSnackBar(
                      context,
                      const CustomSnackBar.success(
                        message: "Gracias por tu opinión. Es de mucha ayuda",
                      ),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                        CupertinoPageRoute<void>(
                            builder: (BuildContext context) {
                      return const Menu();
                    }), (Route<dynamic> route) => false);
                    // Navigator.of(context).pushAndRemoveUntil(
                    //     CupertinoPageRoute<Null>(
                    //         builder: (BuildContext context) {
                    //   return const Inicio();
                    // }), (Route<dynamic> route) => false);
                  },
                  elevation: 0,
                  splashColor: Colors.transparent,
                  child: const Text('Enviar',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 255, 255, 255))),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
