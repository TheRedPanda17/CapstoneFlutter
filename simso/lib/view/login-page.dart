import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:simso/controller/login-page-controller.dart';
import 'package:simso/model/services/iuser-service.dart';
import '../model/entities/user-model.dart';
import '../service-locator.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  BuildContext _context;
  IUserService _userService = locator<IUserService>();
  VideoPlayerController controller;
  LoginPageController _controller;
  UserModel user = UserModel();
  String returnedID;
  var idController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.asset("assets/videos/Posty.mp4")
      // _controller = VideoPlayerController.network(
      //     'http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4')
      ..initialize().then((_) {
        controller.play();
        controller.setLooping(true);
        controller.setVolume(0.0);
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      });
    //controller1 = StartupScreenController(this);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  LoginPageState() {
    _controller = LoginPageController(this, this._userService);
  }

  void stateChanged(Function f) {
    setState(f);
  }

  @override
  Widget build(BuildContext context) {
    this._context = context;
    return MaterialApp(
      theme: ThemeData(
        primaryTextTheme: Typography(platform: TargetPlatform.iOS).white,
        textTheme: Typography(platform: TargetPlatform.iOS).white,
        fontFamily: 'Quantum',
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        //appBar: AppBar(),
        body: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size?.width ?? 0,
                  height: controller.value.size?.height ?? 0,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 30,
                right: 30,
                top: 200,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      onSaved: _controller.saveEmail,
                      decoration: InputDecoration.collapsed(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                    TextFormField(
                      onSaved: _controller.saveUsername,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Username',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 100,
                      height: 60,
                      buttonColor: Colors.black,
                      child: RaisedButton(
                        child: Text(
                          'Add Data',
                          style: TextStyle(fontSize: 40, color: Colors.white),
                        ),
                        onPressed: _controller.saveUser,
                      ),
                    ),
                    Text(
                      returnedID == null
                          ? ''
                          : 'The ID of your new document has returned',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    TextFormField(
                      onSaved: _controller.saveUserID,
                      controller: idController,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Get Customer By ID',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 100,
                      height: 60,
                      buttonColor: Colors.black,
                      child: RaisedButton(
                        child: Text(
                          'Get User',
                          style: TextStyle(fontSize: 40, color: Colors.white),
                        ),
                        onPressed: _controller.getUserData,
                      ),
                    ),
                    Text('User Email: ${user.email}'),
                    Text('Username: ${user.username}'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
