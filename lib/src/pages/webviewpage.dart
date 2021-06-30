import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController webViewController;

  //플렛폼 관리
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,

      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //새로고침
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }



  Future<bool> _onBackPressed(){
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("윈카를 종료 하시겠습니까?"),
          actions: <Widget>[
            ElevatedButton(
              child: Text("아니오"),
              onPressed: ()=>Navigator.pop(context, false),
            ),
            ElevatedButton(
              child: Text("예"),
              onPressed: ()=>Navigator.pop(context, true),
            )
          ],
        )
    );
  }

  final spinkit = SpinKitCircle(
    size: 50.0,
    color: Color(0xFF434872)
  );


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //back key 방지
      home: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        key: webViewKey,
                        initialUrlRequest: URLRequest(
                            url: Uri.parse("http://15.165.55.102/mobile")),
                        initialOptions: options,
                        pullToRefreshController: pullToRefreshController,
                        onWebViewCreated: (controller) {
                          webViewController = controller;

                          webViewController.addJavaScriptHandler(
                              handlerName: 'cameraTrigger',
                              callback: (args) {

                                Get.toNamed("/camera");

                                // return data to JavaScript side!
                                return {'camera : launched.'};
                              });













                          webViewController.addJavaScriptHandler(
                              handlerName: 'multiPicker',
                              callback: (args) async {

                                print("after load image: $url");
                                String accessToken = args[0]['accessToken'];
                                String orderCd = args[0]['orderCd'];
                                String userCd = args[0]['userCd'];
                                String cmpnyCd = args[0]['cmpnyCd'];

                              /*  // get the CookieManager instance
                                CookieManager cookieManager = CookieManager.instance();

                                // get a cookie
                                Cookie userCd= await cookieManager.getCookie(url: Uri.parse(url), name: "userCd");
                                Cookie cmpnyCd = await cookieManager.getCookie(url: Uri.parse(url), name: "cmpnyCd");*/

                                /*print("userCd is ${userCd.value}");
                                print("cmpnyCd is ${cmpnyCd.value}");
                                print("엑세스 토큰 값 = $accessToken");*/

                                Get.toNamed("/picker", arguments: {'accessToken': accessToken, 'userCd': userCd ,'cmpnyCd': cmpnyCd, 'orderCd': orderCd});

                                // return data to JavaScript side!
                                return {'Image uploaded'};
                              });
                        },
                        onLoadStart: (controller, url) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        androidOnPermissionRequest:
                            (controller, origin, resources) async {
                          return PermissionRequestResponse(
                              resources: resources,
                              action: PermissionRequestResponseAction.GRANT);
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          var uri = navigationAction.request.url;

                          if (![
                            "http",
                            "https",
                            "file",
                            "chrome",
                            "data",
                            "javascript",
                            "about"
                          ].contains(uri.scheme)) {
                            if (await canLaunch(url)) {
                              // Launch the App
                              await launch(
                                url,
                              );
                              // and cancel the request
                              return NavigationActionPolicy.CANCEL;
                            }
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStop: (controller, url) async {
                          pullToRefreshController.endRefreshing();
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                            print("url now : $url");
                          });
                        },
                        onLoadError: (controller, url, code, message) {
                          pullToRefreshController.endRefreshing();
                        },
                        onProgressChanged: (controller, progress) {
                          if (progress == 100) {
                            pullToRefreshController.endRefreshing();
                          }
                          setState(() {
                            this.progress = progress / 100;
                            urlController.text = this.url;
                          });
                        },
                        onUpdateVisitedHistory:
                            (controller, url, androidIsReload) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          print(consoleMessage);
                        },
                      ),

                      progress < 1.0
                          ? spinkit
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
