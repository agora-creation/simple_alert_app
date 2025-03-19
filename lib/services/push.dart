import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';

class PushService {
  Future init() async {
    //FCMトークンを取得
    final messagingInstance = FirebaseMessaging.instance;
    messagingInstance.requestPermission();
    String? fcmToken = await messagingInstance.getToken();
    print('fcmToken: $fcmToken');
    if (fcmToken != null) {
      await setPrefsString('fcmToken', fcmToken);
    } else {
      await removePrefs('fcmToken');
    }
    //初期化
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isAndroid) {
      final androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          'default_notification_channel',
          kAppShortName,
          importance: Importance.max,
        ),
      );
      await androidImplementation?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await messagingInstance.requestPermission();
      // iOSでフォアグランド通知を行うための設定
      await messagingInstance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // バックグラウンド起動中に通知をタップした場合の処理
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final android = message.notification?.android;

      // フォアグラウンド起動中に通知が来た場合の処理

      // フォアグラウンド起動中に通知が来た場合、
      // Androidは通知が表示されないため、ローカル通知として表示する
      // https://firebase.flutter.dev/docs/messaging/notifications#application-in-foreground
      if (Platform.isAndroid) {
        // プッシュ通知をローカルから表示する
        await FlutterLocalNotificationsPlugin().show(
          0,
          notification!.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'default_notification_channel',
              kAppShortName,
              importance: Importance.max, // 通知の重要度の設定
              icon: android?.smallIcon,
            ),
          ),
          payload: json.encode(message.data),
        );
      }
    });
    // ローカルから表示したプッシュ通知をタップした場合の処理を設定
    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ), //通知アイコンの設定は適宜行ってください
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final payloadMap =
              json.decode(details.payload!) as Map<String, dynamic>;
          print(payloadMap.toString());
        }
      },
    );
  }

  Future<String?> getFcmToken() async {
    return await getPrefsString('fcmToken');
  }
}
