import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificacionesPush{
  static FirebaseMessaging mensaje = FirebaseMessaging.instance;
  static String? token;
  static final StreamController<String> _messageStreamController = StreamController.broadcast();
  static Stream<String> get messageStream => _messageStreamController.stream;

  static Future _backgraundHanddler(RemoteMessage message) async{
    print('background handler ${message.messageId}');

    _messageStreamController.add(message.notification?.title??'Sin título');
  }
  static Future _onMessageHanddler(RemoteMessage message) async{
    print('on message handler ${message.messageId}');
    _messageStreamController.add(message.notification?.title??'Sin título');
  }
  static Future _onOpenAppHanddler(RemoteMessage message) async{
    print('app abierta handler ${message.messageId}');
    _messageStreamController.add(message.notification?.title??'Sin título');
  }


  static Future iniciarApp() async{
    // push notification
   await Firebase.initializeApp();
   token = await FirebaseMessaging.instance.getToken();
   print('mi Tockeeeeeeeeeeeeeeeeeeee');
   print(token);
   
       // local notification




  // manjadores
  FirebaseMessaging.onBackgroundMessage((_backgraundHanddler));
  FirebaseMessaging.onMessage.listen((_onMessageHanddler));
  FirebaseMessaging.onMessageOpenedApp.listen((_onOpenAppHanddler));

  }

  static closeStream(){
    _messageStreamController.close();
  }

}