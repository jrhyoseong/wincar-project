import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wincar_demo/src/camera/camerapage.dart';
import 'package:wincar_demo/src/camera/checkpage.dart';
import 'package:wincar_demo/src/upload_image/pickerpage.dart';
import 'package:wincar_demo/src/webviewpage.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.photos.request();

  // 디바이스에서 이용가능한 카메라 목록을 받아옵니다.
  final cameras = await availableCameras();
  // 이용가능한 카메라 목록에서 특정 카메라를 얻습니다.
  final firstCamera = cameras.first;


  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(MyApp(camera: firstCamera,));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final CameraDescription camera;

  const MyApp({Key key, this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarBrightness: Brightness.light // Dark == white status bar -- for IOS.
    ));
    return GetMaterialApp(
      title: 'Wincar Demo',
      initialRoute: "/webview",
      getPages: [
        GetPage(
          name: "/webview",
          page: ()=>(WebViewPage()),
        ),
        GetPage(
          name:"/picker",
          page: ()=>(PickerPage()),
        ),
        GetPage(
          name:"/camera",
          page: ()=>(CameraPage(camera: camera,)),
        ),
        GetPage(
          name:"/checkpage",
          page: ()=>(CheckPage()),
        ),
      ],
    );
  }
}
