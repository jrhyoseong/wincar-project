import 'dart:convert';

import 'package:dio/dio.dart';

class Server {
  Response response;

  void getHttp() async {
    try {
      var response = await Dio().get('http://15.165.55.102/mobile');
      var statusCode = response.statusCode;

      String responseBody = utf8.decode(response.data);
      var json = jsonDecode(responseBody);

      if (statusCode == 200) {
        return print('success!!');
      } else {
        return print('failed!!');
      }

      //print(response.data);
    } catch (e) {
      print(e);
    }
  }

  /*
  * multipart form data upload function
  * */
  Future<void> imageUpload({
    List<String> paths,
    String classTy,
    String foldername,
    String orderCd,
    String userCd,
    String cmpnyCd,
    String accessToken
  }) async {

    var options = BaseOptions(
      //mobileapi/v1/user/order/{orderCd}/photos/create
      baseUrl: 'http://15.165.55.102',
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: {'accessToken':'$accessToken'}
    );


    Dio dio = Dio(options);

    List<MultipartFile> fileList = <MultipartFile>[];


    /*
    * check data
    * */
    print("In dio_server : " + paths.toString());

    print("paths values " + paths[0]);

    for (int i = 0; i < paths.length; i++){
      //path에서 값 가져오기

      print("paths $i 번 경로 :" + paths[i]);

      fileList.add( await MultipartFile.fromFileSync(paths[i],
          filename: paths[i].split('/').last));

      print("imagename : " + paths[i].split("/").last);
    }

    print('@@@ fileList @@@ : ' + fileList.toString());

    /*
    * userCd : 사용자 코드
      cmpnyCd : 기업코드
      orderCd : 주문코드
    *
    * */

    var formData = FormData.fromMap({
      'userCd': userCd,
      'cmpnyCd':cmpnyCd,
      'orderCd': orderCd,
      'classTy': classTy,
      'subClassNm': foldername,
      'uploadPhoto': fileList
    });

    print('paths @@ ' + paths.toString());
    print('classTy @@ ' + classTy);
    print('foldername @@ ' + foldername);
    print('orderCd @@ ' + orderCd);
    print('userCd @@ ' + userCd);
    print('cmpnyCd @@ ' + cmpnyCd);
    print('accessToken @@ ' + accessToken);


    response = await dio.post('/mobileapi/v1/user/order/$orderCd/photos/create', data: formData);


    print('@@@ image upload 결과 @@@ : ' + response.statusCode.toString());
  }

  /*
  * test
  * */
  void test({
      List<String> paths,
      String classTy,
      String foldername,
      String orderCd,
      String userCd,
      String cmpnyCd,
      String accessToken}) {

    print('paths @@ ' + paths.toString());
    print('classTy @@ ' + classTy);
    print('foldername @@ ' + foldername);
    print('orderCd @@' + orderCd);
    print('userCd @@ ' + userCd);
    print('cmpnyCd @@ ' + cmpnyCd);
    print('accessToken @@ ' + accessToken);

    }






  }
Server server = Server();
