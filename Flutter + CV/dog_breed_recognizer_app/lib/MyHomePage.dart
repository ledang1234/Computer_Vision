import 'package:camera/camera.dart';
import 'package:dog_breed_recognizer_app/main.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  bool isWorking = false;
  String result="";
  late CameraController cameraController;
  CameraImage? imgCamera  = null;

  initCamera()
  {
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((value)
    {
      if(!mounted)
      {
        return;
      }

      setState(() {
        cameraController.startImageStream((imageFromStream) =>
        {
          if(!isWorking)
            {
              isWorking = true,
              imgCamera = imageFromStream,
              runModelOnStreamFrames(),
            }
        });
      });
    });
  }

  runModelOnStreamFrames() async
  {
    if(imgCamera != null)
    {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: imgCamera!.planes.map((plane)
        {
          return plane.bytes;
        }).toList(),

        imageHeight: imgCamera!.height,
        imageWidth: imgCamera!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );

      result = "";

      recognitions!.forEach((response)
      {
        result += response["label"] + "  " + (response["confidence"] as double).toStringAsFixed(2) + "\n\n";
      });

      setState(() {
        result;
      });

      isWorking = false;
    }
  }

  loadModel() async
  {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void initState() {
    super.initState();
    // initCamera();
    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();

    await Tflite.close();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage("assets/back.jpg"),
              //   fit: BoxFit.fill,
              // ),
              color:Colors.yellowAccent
            ),
            child: Column(
              children: [
                Stack(
                  children: [

                    Center(
                      child: Container(
                        height: 320,
                        width: 360,
                        // child: Image.asset("assets/frame.jpg"),
                        color: Colors.white,
                      ),
                    ),

                    Center(
                      child: FlatButton(
                        onPressed: ()
                        {
                          initCamera();
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 35),
                          height: 270,
                          width: 360,
                          child: imgCamera == null
                              ? Container(
                            height: 270,
                            width: 360,
                            child: Icon(Icons.photo_camera_front, color: Colors.blueAccent, size: 40,),
                          )
                              : AspectRatio(
                            aspectRatio: cameraController.value.aspectRatio,
                            child: CameraPreview(cameraController),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 55.0),
                    child: SingleChildScrollView(
                      child: Text(
                        result,
                        style: TextStyle(
                          backgroundColor: Colors.white54,
                          fontSize: 25.0,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
