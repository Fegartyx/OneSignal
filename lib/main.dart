import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void setOneSignal() async {
  //Remove this method to stop OneSignal Debugging
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  OneSignal.shared.setAppId("b24a879f-74ce-47cf-8e55-421a92cfdc61");

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    debugPrint("Accepted permission: $accepted");
  });
}

void setLocalNotif(
    BuildContext context, OSNotificationReceivedEvent event) async {
  await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveBackgroundNotificationResponse: (payload) {});
}

@pragma("vm:entry-point")
Future<void> showNotifications(OSNotificationReceivedEvent event) async {
  AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(100).toString(), "High Importance Notification",
      importance: Importance.max);

  AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(channel.id, channel.name,
          channelDescription: 'Desc',
          importance: channel.importance,
          priority: Priority.high,
          ticker: "ticker");

  DarwinNotificationDetails darwinNotificationDetails =
      const DarwinNotificationDetails(
          presentAlert: true, presentBadge: true, presentSound: true);

  NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails, iOS: darwinNotificationDetails);

  flutterLocalNotificationsPlugin.show(0, event.notification.title!,
      event.notification.body!, notificationDetails);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setOneSignal();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String title = "title";
  String content = "content";
  String? url = "";

  void setNotif() {
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      showNotifications(event);
      setState(() {
        title = event.notification.title!;
        content = event.notification.body!;
        url = event.notification.bigPicture!;
      });
      // Will be called whenever a notification is received in foreground
      // Display Notification, pass null param for not displaying the notification
      // event.complete(event.notification);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setNotif();
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // Will be called whenever a notification is opened/button pressed.
      debugPrint("Notification Pressed");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      debugPrint("Permission Changes");
      // Will be called whenever the permission changes
      // (ie. user taps Allow on the permission prompt in iOS)
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      // Will be called whenever the subscription changes
      // (ie. user gets registered with OneSignal and gets a user ID)
    });

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges emailChanges) {
      // Will be called whenever then user's email subscription changes
      // (ie. OneSignal.setEmail(email) is called and the user gets registered
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("OneSignal"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
            ),
            Text(
              content,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            (url != "") ? Image.network(url!) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
