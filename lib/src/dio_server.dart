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
    );


    Dio dio = Dio(options);

    List<MultipartFile> fileList = <MultipartFile>[];

    Map uploadPhotos = new Map();

    var formData = FormData.fromMap({
      'userCd': userCd,
      'cmpnyCd':cmpnyCd,
      'orderCd': orderCd,
      'classTy': classTy,
      'subClassNm': foldername,
      //'uploadPhoto': fileList,
      'accessToken':accessToken
    });

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

      //uploadPhotos['uploadPhoto${i}'] = await MultipartFile.fromFileSync(paths[i], filename: paths[i].split('/').last);

      formData.files.add(MapEntry('uploadPhoto${i}', await MultipartFile.fromFileSync(paths[i], filename: paths[i].split('/').last)));

      print("imagename ${i} 번: " + paths[i].split("/").last);

    } //for문

    print('@@@ fileList @@@ : ' + fileList.toString());
    print('paths @@ ' + paths.toString());
    print('classTy @@ ' + classTy);
    print('foldername @@ ' + foldername);
    print('orderCd @@ ' + orderCd);
    print('userCd @@ ' + userCd);
    print('cmpnyCd @@ ' + cmpnyCd);
    print('accessToken @@ ' + accessToken);


    response = await dio.post('/mobileapi/v1/user/order/$orderCd/photos/create', data: formData);


    print('@@@ image upload 결과 @@@ : ' + response.statusCode.toString());
    print('@@@ image upload 결과 @@@ : ' + response.statusMessage);
    print(response.toString());

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
