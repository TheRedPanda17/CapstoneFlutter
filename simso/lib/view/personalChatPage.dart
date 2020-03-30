import 'package:cached_network_image/cached_network_image.dart';
import 'package:simso/controller/mainChatPage-controller.dart';
import 'package:simso/controller/personalChatPage-controller.dart';
import 'package:simso/model/entities/message-model.dart';
import 'package:simso/model/entities/myfirebase.dart';
import 'package:simso/model/services/itouch-service.dart';
import 'package:simso/view/navigation-drawer.dart';
import 'package:flutter/material.dart';
import 'package:simso/model/services/itimer-service.dart';
import 'package:simso/model/services/iuser-service.dart';
import '../model/entities/user-model.dart';
import '../service-locator.dart';
import 'design-constants.dart';

class PersonalChatPage extends StatefulWidget {
  final UserModel user;
  int index; //index of selected Simso
  List<UserModel>userList;
  PersonalChatPage(this.user, this.index,this.userList);        //Receive data from mainChatPage controller

  @override
  State<StatefulWidget> createState() {
    return PersonalChatPageState(user, index,userList);
  }
}

class PersonalChatPageState extends State<PersonalChatPage> {
  BuildContext context;
  IUserService userService = locator<IUserService>();
  ITimerService timerService = locator<ITimerService>();
  ITouchService touchService = locator<ITouchService>();
  PersonalChatPageController controller;
  UserModel user;
  int index;
  String returnedID;
  var idController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  bool publicFlag = false;
  List<UserModel>userList;
  PersonalChatPageState(this.user,this.index,this.userList) {
    controller = PersonalChatPageController(this);
  
  }
  
  void stateChanged(Function f) {
    setState(f);
  }
 
  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      backgroundColor: DesignConstants.blue,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: new Column(
            children: <Widget>[
              //Display profile picture
              userList[index].profilePic == '' ? Icon(Icons.tag_faces)
              :CachedNetworkImage(imageUrl: userList[index].profilePic, height:30),
          
              //Display username
              Text('${userList[index].username}',style: TextStyle(fontSize: 15),),
              
             
            ],
            //Text('${userList[index].username} '),
        ),
        backgroundColor: DesignConstants.blue,
      ),
      body: //Text('Personal Chat Screen with SimSo index $index'),
      
      Column(
        
        children: <Widget>[

          Expanded(
            child: Container(
             decoration: BoxDecoration(
               color: DesignConstants.blue, 
               borderRadius: BorderRadius.only(
                 topLeft:Radius.circular(30),
                 topRight: Radius.circular(30)
               )
               ),      
                    
            ),
          ),
              
              Form(
                  key: formKey,
                  child: TextFormField(
                  scrollPadding: EdgeInsets.all(8),
                  decoration: InputDecoration(
                        
                        hintText: 'enter your message',
                        hintStyle: TextStyle(color: DesignConstants.yellow),
                        contentPadding: EdgeInsets.all(10),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: DesignConstants.yellow,width:3)
                        ),
                        
                        labelStyle: TextStyle(color: DesignConstants.yellow),
                      ),
                      validator: controller.validateTextMessage,
                      onSaved: controller.saveTextMessage,
                      onFieldSubmitted: (key){key='';},
                      autocorrect: true,

                      style: TextStyle(color: DesignConstants.yellow,fontStyle: FontStyle.italic)
                ),
              ),
          
                Row(
                  children: <Widget>[        
                IconButton(
                  icon: Icon(Icons.photo, color: DesignConstants.yellow,),
                  onPressed: null
                  ),
                 IconButton(
                  icon: Icon(Icons.send, color: DesignConstants.yellow,),
                  onPressed: controller.send,
                  ),
      

                  ],
                ),
              
              
          
            //Show message    
             
            
          

          
         
           
        ],
       
       
      ),
     
       
    );
    
}

}