// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, prefer_typing_uninitialized_variables

import 'dart:async';

import 'package:chamber/features/saved/savedImages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:native_shutter_sound/native_shutter_sound.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin {
  late StreamSubscription subscription;
  final wsUrl = Uri.parse('ws://192.168.0.1:8888');
  late WebSocketChannel channel;
  late StreamController streamController;
  late Timer timer;

  var isDeviceConnected = false;
  var runningStream = false;

  final info = NetworkInfo();
  ScreenshotController screenshotController = ScreenshotController();

  int count = 0;

  // bool  = false;

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    checkWifiInfo();
    initTimer();
  }

  initTimer() {
    timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (runningStream == true) {
        if (channel.closeCode != null) {
          runningStream = false;
          isDeviceConnected = false;
        }
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20)),
                      child: isDeviceConnected
                          ? runningStream
                              ? Container(
                                  child: sensorData(),
                                )
                              : Container(
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LoadingAnimationWidget.threeArchedCircle(
                                          color: Colors.black87, size: 36),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "UV Chamber is getting connected ...",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                          : Center(
                              child: GestureDetector(
                              onTap: checkWifiInfo,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        Colors.yellow,
                                        BlendMode.modulate,
                                      ),
                                      child: Lottie.asset(
                                          'assets/findWifi.json',
                                          height: 130,
                                          width: 130)),
                                  GestureDetector(
                                    onTap: () {
                                      checkWifiInfo();
                                    },
                                    child: Container(
                                      height:
                                          MediaQuery.sizeOf(context).height /
                                              12,
                                      width:
                                          MediaQuery.sizeOf(context).width / 2,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white),
                                      child: Text(
                                        "Check",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "You are not Connected to Wifi\nplease ensure you are connected",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: isDeviceConnected
                                ? Icon(
                                    Icons.wifi_sharp,
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.wifi_off,
                                    size: 30,
                                  ),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(50))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width / 4,
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: CircleBorder()),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: SavedImages()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.image,
                              size: 30,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, shape: CircleBorder()),
                      onPressed: () async {
                        NativeShutterSound.play();
                        final directory =
                            (await getApplicationDocumentsDirectory())
                                .path; //from path_provide package
                        String fileName =
                            "compuRFImage_${DateTime.now().microsecondsSinceEpoch.toString()}";
                        String path = directory;
                        print(directory);
                        await screenshotController.captureAndSave(
                            "/data/data/com.example.chamber/images" //set path where screenshot will be savedm,
                            ,
                            fileName: fileName);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.camera,
                          size: 50,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width / 4,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.image,
                            size: 30,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  StreamBuilder<dynamic> sensorData() {
    return StreamBuilder(
      stream: streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // var screenWidth = MediaQuery.of(context).size.width;
          // var screenHeight = MediaQuery.of(context).size.height;
          return Container(
            child: Center(
              child: RotatedBox(
                quarterTurns: -45,
                child: Screenshot(
                  controller: screenshotController,
                  child: Image.memory(
                    snapshot.data,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  void checkWifiInfo() async {
    print("hi");
    String? wifi = await info.getWifiName();
    print('wifi pringing ');
    print(wifi);
    if (wifi == "\"PHARMA\"") {
      setState(() {
        isDeviceConnected = true;
      });
      connectWebSocket();
    }
  }

  void connectWebSocket() async {
    try {
      channel = IOWebSocketChannel.connect(wsUrl);

      await channel.ready;
      streamController = StreamController.broadcast();
      streamController.addStream(channel.stream);
      // print(channel.stream.listen);

      streamController.stream.listen((message) async {
        // print(await streamController.stream.isEmpty);
        if (mounted) {
          setState(() {
            // print(message);
            if (message == 'connected') {
              runningStream = true;
            }
          });
        }

        // print(state);
      });
    } catch (e) {}

    // print(state);
  }
}
