import 'package:flutter/material.dart';


class InformacionConductor extends StatefulWidget {
  final String idConductor;

  const InformacionConductor({Key? key, required this.idConductor}) : super(key: key);
  @override
  State<InformacionConductor> createState() => _InformacionConductorState();
}

class _InformacionConductorState extends State<InformacionConductor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.amber,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
          title: const Text(
            'Conductor',
            style: TextStyle(fontSize: 12),
          ),
          centerTitle: true,
          // actions: <Widget>[            
          //   widget.origen == 'PASAJERO'
          //   ? idConductor == ''
          //     ? const Text('-')
          //     : TextButton(
          //     onPressed: () {
          //       Navigator.of(context).push(
          //           CupertinoPageRoute<void>(builder: (BuildContext context) {
          //         return InformacionConductor(idConductor: idConductor);
          //       }));
          //     },
          //     child: const Icon(
          //       Icons.badge_outlined,
          //       color: Colors.amber,
          //     ),
          //   )
          //   : const SizedBox(height: 0,),
          // ],
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
              ),
              onPressed: () => Navigator.of(context).pop(),
            );
          })),
        body: Column(
          children:  [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                    decoration: BoxDecoration(                     
                      borderRadius: BorderRadius.circular(150),
                      color: const Color.fromARGB(255, 255, 255, 255),
                      border: Border.all(width: 6,color: Colors.white)
                    ),
                    // color: Colors.white,
                    height: 150,
                    width: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(150),
                      child: Image.asset(
                        'assets/images/png/default/taxi.jpg',fit: BoxFit.cover,
                        // scale: 2.8,
                        // color: const Color.fromRGBO(253, 189, 16, 1),
                      ),
                    ),
                                ),
                  ),
                  const SizedBox(height: 10,),
                  const Text('Juan victor Ruiz Trujillo',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 14),),
                  const SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.star_rate_rounded,color: Colors.amber),
                      Icon(Icons.star_rate_rounded,color: Colors.amber),
                      Icon(Icons.star_rate_rounded,color: Colors.amber),
                      Icon(Icons.star_rate_rounded,color: Colors.amber),
                      Icon(Icons.star_half_rounded,color: Colors.amber),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: const [
                            Text('Dni',style: TextStyle(color: Colors.grey,fontSize: 12),),
                            SizedBox(height: 5,),
                            Text('77271360',style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w500),)
                          ],
                        ),
                        Column(
                          children: const [
                            Text('Placa',style: TextStyle(color: Colors.grey,fontSize: 12),),
                            SizedBox(height: 5,),
                            Text('ABC123',style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w500),)
                          ],
                        ),
                        Column(
                          children: const [
                            Text('Modelo',style: TextStyle(color: Colors.grey,fontSize: 12),),
                            SizedBox(height: 5,),
                            Text('Mazda',style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w500),)
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}