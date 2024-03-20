import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//���˵����ӣ�main��û��ʹ��https://blog.csdn.net/weixin_41897680/article/details/131947231
class NotificationHelper {
  // ʹ�õ���ģʽ���г�ʼ��
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  // FlutterLocalNotificationsPlugin��һ�����ڴ�����֪ͨ�Ĳ�������ṩ����FlutterӦ�ó����з��ͺͽ��ձ���֪ͨ�Ĺ��ܡ�
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ��ʼ������
  Future<void> initialize() async {
    // AndroidInitializationSettings��һ����������Android�ϵı���֪ͨ��ʼ������
    // ʹ����app_icon��Ϊ����������ζ����Android�ϣ�Ӧ�ó����ͼ�꽫����������֪ͨ��ͼ�ꡣ
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // 15.1��DarwinInitializationSettings���ɰ汾������IOSInitializationSettings����Щ�����о��������
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    // ��ʼ��
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await _notificationsPlugin.initialize(initializationSettings);
  }

//  ��ʾ֪ͨ
  Future<void> showNotification(
      {required String title, required String body}) async {
    // ��׿��֪ͨ
    // 'your channel id'������ָ��֪ͨͨ����ID��
    // 'your channel name'������ָ��֪ͨͨ�������ơ�
    // 'your channel description'������ָ��֪ͨͨ����������
    // Importance.max������ָ��֪ͨ����Ҫ�ԣ�����Ϊ��߼���
    // Priority.high������ָ��֪ͨ�����ȼ�������Ϊ�����ȼ���
    // 'ticker'������ָ��֪ͨ����ʾ�ı�����֪ͨ������֪ͨ���ĵ��ı����ݡ�
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your.channel.id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    // ios��֪ͨ
    const String darwinNotificationCategoryPlain = 'plainCategory';
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain, // ֪ͨ����
    );
    // ������ƽ̨֪ͨ
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    // ����һ��֪ͨ
    await _notificationsPlugin.show(
      1,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
