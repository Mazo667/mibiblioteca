import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void initNotifications(BuildContext context) async {
  var fcmToken = await FirebaseMessaging.instance.getToken();
  print("el token");
  print("FCM token: " + (fcmToken ?? "no token"));

  initLocalNotifications(context);
  initPushNotifications();
}

void initPushNotifications() {
  FirebaseMessaging.onMessage.listen(_onRemoteMessageReceived);
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessageReceived);
}

Future<void> _onBackgroundMessageReceived(RemoteMessage message) async {
  print("Notificación recibida en background");
  print("Título: " + (message.notification?.title ?? "sin title"));
  print("Body: " + (message.notification?.body ?? "sin body"));
}

void _onRemoteMessageReceived(RemoteMessage message) {
  _showNotification(message.notification?.title ?? "sin título",
      message.notification?.body ?? "sin body");
}

void initLocalNotifications(BuildContext context) async {
  FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  notifications.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

  DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {
        //TODO mostrar notificación para iOS menor a 10
      });

  AndroidInitializationSettings androidSettings =
  const AndroidInitializationSettings('mipmap/ic_launcher');

  InitializationSettings initSettings =
  InitializationSettings(iOS: iosSettings, android: androidSettings);

  await notifications.initialize(initSettings,
      onDidReceiveNotificationResponse: (payload) async {
        await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text("Notificación apretada"),
              content: Text(payload! as String),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancelar'),
                  child: const Text('Ok!'),
                ),
              ],
            ));

      });


  //Esto sólo es para ejemplificar su uso
  startReadingReminder();
}

void startReadingReminder() {
  // Setear un recordatorio para que el usuario lea cada cierto tiempo, i.e.: todos los días a las 22.00
  // TODO agregar una pantalla donde los usuarios puedan activar/desactivar y configurar esto.
  Future.delayed(const Duration(seconds: 4), () {
    print("Por llamar la funcion de notificar");
    _showNotification(
        "Un mensaje de tu amigo Booksy", "Recordatorio para leer");
  });
}

void _showNotification(String title, String body) {
  print("Llamando la funcion de notificar");
  FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();
  const AndroidNotificationDetails androidSpecifics =
  AndroidNotificationDetails(
      'you_can_name_it_whatever1',
      'channel_name',
      playSound: true,
      importance: Importance.max,
      priority: Priority.high);

  notifications.show(
      0, title, body, const NotificationDetails(android: androidSpecifics),
      payload: "20");
}