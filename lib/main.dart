import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '心率Gps和wifi'),
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
  int _counter = 0;
  late WebSocketChannel channel;

/*   void _incrementCounter() {
    setState(() {
      
      _counter++;
    });
  } */
  @override
  void initState() {
    try {
      channel = IOWebSocketChannel.connect('ws://192.168.43.30:80');
      channel.stream.listen((event) {
        //处理websocket传输的信息，血氧，心率，经纬度
        print(event);
        List<String> lines = event.split('\n');
        for (String line in lines) {
          if (line.startsWith('PW:')) {
            latitude = double.parse(line.split(':')[1]);
          } else if (line.startsWith('PJ:')) {
            longitude = double.parse(line.split(':')[1]);
          } else if (line.startsWith('heart:')) {
            heart = int.parse(line.split(':')[1]);
            print(heart);
          } else if (line.startsWith('SpO2:')) {
            SPO2 = double.parse(line.split(':')[1]);
            print(SPO2);
          }
          setState(() {
            // 更新状态
            //心率大于120就打开弹窗
            if (heart > 120) {
              showheartDialog();
              showNotification();
            }
            if (SPO2 < 89) {
              showSPO2eartDialog();
              showNotification();
            }
          });
        }
      }, //监听服务器消息
          onError: (error) {
        print("服务器连接错误");
      }, //连接错误时调用
          onDone: () {
        print("服务器已关闭");
      },
          //关闭时调用
          cancelOnError: true //设置错误时取消订阅
          );
    } catch (e) {
      print("发生异常：$e");
    }
    super.initState();
  }

////////对websocket的消息接收
  final TextEditingController _controller = TextEditingController();
  // final _channel = WebSocketChannel.connect(
  //   Uri.parse('ws://193.168.43.30:80'),
  // );
////////
  //时间和经纬度
  double latitude = 0.0;
  double longitude = 0.0;
  int heart = 78;
  double SPO2 = 90.0;
  String time = '';

  ///////////弹出窗口
  void showheartDialog() //心率弹出窗口
  {
    var dialog = CupertinoAlertDialog(
      title: Text('是否拨打120？'),
      content: Text(
        "检测到佩戴者的心率过高",
        style: TextStyle(fontSize: 20),
      ),
      actions: <Widget>[
        CupertinoButton(
          child: Text(
            "确定",
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            launchUrl(Uri(
              scheme: 'tel',
              path: "120",
            ));
            Navigator.pop(context);
          },
        ),
        CupertinoButton(
          child: Text("取消", style: TextStyle(color: Colors.blueGrey)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  void showSPO2eartDialog() //血氧弹出窗口
  {
    var dialog = CupertinoAlertDialog(
      title: Text('是否拨打120？'),
      content: Text(
        "检测到佩戴者的血氧过低",
        style: TextStyle(fontSize: 20),
      ),
      actions: <Widget>[
        CupertinoButton(
          child: Text(
            "确定",
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            launchUrl(Uri(
              scheme: 'tel',
              path: "120",
            ));
            Navigator.pop(context);
          },
        ),
        CupertinoButton(
          child: Text("取消", style: TextStyle(color: Colors.blueGrey)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }

//程序运行外显示通知
  Future<void> showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      '使用者有危险',
      '请拨打120',
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              //心率
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(width: 1.0, color: Colors.black)),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(CupertinoIcons.heart_solid),
                ),
              ),
              title: Text("心率(/min)"),
              trailing: Text("$heart"),
            ),
            ListTile(
              //血氧饱和度
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    border: Border(right: BorderSide(width: 1.0))),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.bloodtype),
                ),
              ),
              title: Text("血氧饱和度(%)"),
              trailing: Text("$SPO2"),
            ),
            ListTile(
              //经度
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    border: Border(right: BorderSide(width: 1.0))),
                child: Image.asset(
                  'assets/images/PJ.png',
                  width: 40,
                  height: 40,
                  // 图片路径
                ),
              ),
              title: Text("经度"),
              trailing: Text("$latitude"),
            ),
            // ListTile(
            //   contentPadding:
            //       EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            //   leading: Container(
            //     padding: EdgeInsets.zero,
            //     decoration: BoxDecoration(
            //         border: Border(right: BorderSide(width: 1.0))),
            //     child: IconButton(
            //       onPressed: () {},
            //       icon: Icon(Icons.device_thermostat),
            //     ),
            //   ),
            //   title: Text("室温(℃)"),
            //   trailing: Text("32.2"),
            // ),
            ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                leading: Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                      border: Border(right: BorderSide(width: 1.0))),
                  child: Image.asset(
                    'assets/images/PW.png',
                    width: 40,
                    height: 40,
                    // 图片路径
                  ),
                ),
                title: Text("纬度"),
                trailing: Text("$longitude")),
            // StreamBuilder(
            //   stream: _channel.stream,
            //   builder: (context, snapshot) {
            //     print(snapshot.hasData);
            //     if (snapshot.hasData) {
            //       print("1321223155213");
            //       String data = snapshot.data;
            //       List<String> lines = data.split('\n');
            //       for (String line in lines) {
            //         if (line.startsWith('PW:')) {
            //           latitude = double.parse(line.split(':')[1]);
            //         } else if (line.startsWith('PJ:')) {
            //           longitude = double.parse(line.split(':')[1]);
            //         } else if (line.startsWith('heart:')) {
            //           heart = int.parse(line.split(':')[1]);
            //           print(heart);
            //         } else if (line.startsWith('SpO2:')) {
            //           SPO2 = double.parse(line.split(':')[1]);
            //           print(SPO2);
            //         }
            //       }
            //     }
            //     return Text(snapshot.hasData ? '${snapshot.data}' : '');
            //   },
            // ),
            // Form(
            //   child: TextFormField(
            //     controller: _controller,
            //     decoration: const InputDecoration(labelText: 'Send a message'),
            //   ),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNotification,
        tooltip: 'Increment',
        child: const Icon(Icons.info),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    // _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }
}
