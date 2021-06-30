import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class CheckPage extends StatelessWidget {
  XFile image = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
            children: [
              Container(
                child: Row(
                  children: [
                    Expanded(child: Image.file(File(image.path) ,fit: BoxFit.fill,),),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                              onPrimary: Colors.white,
                            ),
                            onPressed: () {
                              Get.back();
                            },
                            child: Text("다시찍기")),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                              onPrimary: Colors.white,
                            ),
                            onPressed: () {
                              GallerySaver.saveImage(image.path)
                                  .then((bool success) {
                                print("success : $success");
                              });
                              Get.back();
                            },
                            child: Text("저장하기")),
                      ],
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5))),
                  ),
                ],
              )
            ],
          ),

      ),
    );
  }
}
