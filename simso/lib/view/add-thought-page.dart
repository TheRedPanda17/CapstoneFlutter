import 'package:flutter/material.dart';
import 'package:unicorndial/unicorndial.dart'; //add in save icon as unicorn button
import '../model/entities/user-model.dart';
import '../model/entities/thought-model.dart';
import '../view/design-constants.dart';
import '../view/navigation-drawer.dart';
import '../controller/add-thought-controller.dart';

class AddThoughtPage extends StatefulWidget {
  final UserModel user;

  AddThoughtPage(this.user);

  @override
  State<StatefulWidget> createState() {
    return AddThoughtPageState(user);
  }
}

class AddThoughtPageState extends State<AddThoughtPage> {
  BuildContext context;
  AddThoughtController controller;

  UserModel user;
  Thought thought;
  Thought
      thoughtCopy; //will eventually add deep copy, but for now just new thoughts

  //bool entry = false; //keep, there was something I liked about this snippet of code from Hiep

  var formKey = GlobalKey<FormState>();

  AddThoughtPageState(this.user) {
    controller =
        AddThoughtController(this);
    thoughtCopy = Thought.empty();
  }

  void stateChanged(Function f) {
    setState(f);
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Add a Thought',
            style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 30.0,
                color: DesignConstants.yellow),
          ),
          backgroundColor: DesignConstants.blue,
        ),
        drawer: MyDrawer(context, user),
        body: Container(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                Theme(
                  data: Theme.of(context)
                      .copyWith(splashColor: Colors.transparent),
                  child: TextFormField(
                    autofocus: true,
                    validator: controller.validateText,
                    onSaved: controller.saveText,
                    style: TextStyle(fontSize: 22.0, color: Colors.grey[700]),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Add a thought',
                      hintStyle:
                          TextStyle(fontSize: 20.0, color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.only(
                          left: 14.0, bottom: 8.0, top: 8.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(25.7),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(25.7),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 14.0, bottom: 8.0),
                ),
                Theme(
                  data: Theme.of(context)
                      .copyWith(splashColor: Colors.transparent),
                  child: RaisedButton(
                    child: Text(
                      'Add',
                      style: TextStyle(fontSize: 22.0, color: Colors.grey[900]),
                    ),
                    onPressed: controller.save,
                    padding: EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
