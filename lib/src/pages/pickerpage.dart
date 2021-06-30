import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:get/get.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:wincar_demo/src/dio_server.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PickerPage extends StatefulWidget {
  @override
  _PickerPageState createState() => _PickerPageState();
}

class _PickerPageState extends State<PickerPage> {














    String apiResult;


    String orderCd = Get.arguments['orderCd'];
    String userCd = Get.arguments['userCd'];
    String cmpnyCd = Get.arguments['cmpnyCd'];
    String accessToken = Get.arguments['accessToken'];
    List jsonResult = [];
    String classTy = '';









    // 사진 분류 리스트 api 함
  // 결과 값으로 List<Classfication> list 로 값을 받기로 함.
  // 받은 값 들 중에 필요한 classTyNm을 사용 하여 각 분류에 넣기로 함.
  // 선택한 이름에 값은 연결 ... ?
  Future<void> fetchClassfication() async {

    final response = await http.post(
      Uri.parse('http://15.165.55.102/mobileapi/v1/user/order/photocategrs?userCd=$userCd&cmpnyCd=$cmpnyCd'),
      headers : {'accessToken' : '$accessToken'},
    );

    if(response.statusCode == 200){

      String result = utf8.decode(response.bodyBytes);

      jsonResult = jsonDecode(result)['dataset']['data'];

      //print("jsonResult.toString() 의 값은 "+ jsonResult.toString());

      String classTyNm = "";

      for(int i = 0; i < jsonResult.length; i++){
        classTyNm = jsonResult[i]['classTyNm'];

        selectList.add(classTyNm);
      }

      setState(() {
        // 이곳을 통해서 결과 값들을 전달해야 함.
        apiResult = utf8.decode(response.bodyBytes);
      });

    }else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Classfication of Picture');
    }

  }










  List<Asset> images = <Asset>[];

  List<String> paths = <String>[];

  //분류 리스트
  List<String> selectList = <String>[];

  //선택된 사진 리스트
  List<Asset> resultList = <Asset>[];




  String dropdownValue = "미분류";
  final _folderNameTextEditController = TextEditingController();

  Future<void> loadAssets() async {

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#434872",
          actionBarTitle: "업로드 이미지 선택",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#ffffff",
        ),
      );
    } on Exception catch (e) {
      print(e);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    //사진을 선택하지 않고 돌아갔을 때 홈으로 이동하게 설정
    if (resultList.length == 0) Get.back();

    setState(() {
      images= resultList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //화면 구성
    loadAssets();

    //분류리스트
    fetchClassfication();

    server.getHttp();
  }

  @override
  void dispose() {
    _folderNameTextEditController.dispose();
    super.dispose();
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      padding: EdgeInsets.all(1.0),
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return Padding(
          padding: const EdgeInsets.all(1.0),
          child: AssetThumb(
            asset: asset,
            width: 300,
            height: 300,
          ),
        );
      }),
    );
  }

  Future<void> uploadImage() async {
    //make paths
    String path = "";
    paths = [];
    for (int i = 0; i < resultList.length; i++) {
      //절대 경로 값을 받습니다.
      path = await FlutterAbsolutePath.getAbsolutePath(resultList[i].identifier);

      print(resultList[i].identifier);
      print(resultList[i].name);

      paths.add(path);
    }

    //폴더 값이 null 일 때 현재 시간을 폴더 명으로 한다.
    if(_folderNameTextEditController.text == null || _folderNameTextEditController.text == "" ){
      DateTime dateTime = DateTime.now(); // your dateTime object
      DateFormat dateFormat = DateFormat("yyyyMMdd"); // how you want it to be formatted
      _folderNameTextEditController.text  = dateFormat.format(dateTime);
      print('now date is ' + _folderNameTextEditController.text);
    }

    // dropdownValue 값에 해당하는 classTy의 값을 받아서 값을 전달한다.
    for(int i = 0; i < selectList.length; i++){
      if(selectList[i] == dropdownValue){
        classTy = jsonResult[i]['classTy'];
      }
    }

    server.imageUpload(
        paths: paths,
        classTy: classTy,
        foldername: _folderNameTextEditController.text,
        orderCd: orderCd,
        userCd: userCd,
        cmpnyCd: cmpnyCd,
        accessToken: accessToken
    );

    // Get.back();

    /*test*/
    /*server.test(paths: paths,
        classTy: dropdownValue,
        foldername: _folderNameTextEditController.text,
        orderCd: orderCd,
        userCd: userCd,
        cmpnyCd: cmpnyCd,
        accessToken: accessToken);*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "카테고리 및 폴더명 입력",
        ),
        centerTitle: true,
        backgroundColor: Color(0xff434872),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [Expanded(
            child: ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: 400,
                      color: Colors.grey[200],
                      child: Column(
                        children: [
                          Expanded(
                            child: buildGridView(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 36,
                    ),
                    Container(
                      width: 343,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 230,
                            margin: EdgeInsets.all(0),
                            child: Column(
                              children: [
                                //카테고리
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Container(
                                    height: 45,
                                    //gives the height of the dropdown button
                                    width: MediaQuery.of(context).size.width,
                                    //gives the width of the dropdown button
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(3)),
                                        color: Color(0xFFF2F2F2)),
                                    // padding: const EdgeInsets.symmetric(horizontal: 13), //you can include padding to control the menu items
                                    child: Theme(
                                        data: Theme.of(context).copyWith(
                                          //canvasColor: Colors.yellowAccent,
                                          // background color for the dropdown items
                                            buttonTheme:
                                            ButtonTheme.of(context).copyWith(
                                              alignedDropdown:
                                              true, //If false (the default), then the dropdown's menu will be wider than its button.
                                            )),
                                        child: DropdownButtonHideUnderline(
                                          // to hide the default underline of the dropdown button
                                          child: DropdownButton<String>(
                                            value: dropdownValue,
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: Color(0xff05a3ec),
                                            ),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: const TextStyle(
                                                color: Color(0xff05a3ec)),
                                            onChanged: (String newValue) {
                                              setState(() {
                                                dropdownValue = newValue;
                                              });
                                            },
                                            items: selectList
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                          ),
                                        ),
                                    ),
                                  ),
                                ),
                                //폴더명
                                Container(
                                  height: 60,
                                  child: TextField(
                                    controller: _folderNameTextEditController,
                                    maxLength: 30,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "폴더명"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Color(0xff05a3ec),
                                minimumSize: Size(82, 40)
                              ),
                              onPressed: uploadImage,
                              child: ButtonTheme(
                                child: Text("전송"),
                              ),
                            ),

                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),]
        ),
      ),
    );
  }
}
