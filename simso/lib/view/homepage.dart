import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:simso/model/entities/image-model.dart';
import 'package:simso/model/entities/meme-model.dart';
import 'package:simso/model/entities/message-model.dart';
import 'package:simso/model/entities/myfirebase.dart';
import 'package:simso/model/entities/song-model.dart';
import 'package:simso/model/entities/thought-model.dart';
import 'package:simso/model/services/ilimit-service.dart';
import 'package:simso/model/services/ipicture-service.dart';
import 'package:simso/model/services/itouch-service.dart';
import 'package:simso/view/friends-page.dart';
import 'package:simso/view/music-feed.dart';
import 'package:simso/view/navigation-drawer.dart';
import 'package:simso/view/profile-page.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:flutter/material.dart';
import 'package:simso/controller/homepage-controller.dart';
import 'package:simso/model/services/itimer-service.dart';
import 'package:simso/model/services/iuser-service.dart';
import '../model/entities/user-model.dart';
import '../service-locator.dart';
import 'design-constants.dart';
import '../model/entities/friendRequest-model.dart';
import 'package:simso/model/services/ifriend-service.dart';
import 'package:simso/view/notification-page.dart';
import 'emoji-container.dart';
import '../model/entities/globals.dart' as globals;
import 'package:audioplayers/audioplayers.dart';


class Homepage extends StatefulWidget {
  final UserModel user;
  final List<SongModel> songlist;
   
  Homepage(this.user, this.songlist);

  @override
  State<StatefulWidget> createState() {
    return HomepageState(user);
  }
}

class HomepageState extends State<Homepage> {
  BuildContext context;
  IUserService userService = locator<IUserService>();
  ITimerService timerService = locator<ITimerService>();
  ITouchService touchService = locator<ITouchService>();
  ILimitService limitService = locator<ILimitService>();
  IImageService imageService = locator<IImageService>();
  final IFriendService friendService = locator<IFriendService>();
  bool meme = false;
  bool music = false;
  bool snapshots = false;
  bool thoughts = true;
  bool friends = true;
  bool visit = false;
  bool play = false;
  bool pause = true;
  bool leave = false;
  List<Thought> friendsThoughtsList =
      []; //changed variable name because this is the friends thought list not the public one
  HomepageController controller;
  UserModel user;
  List<SongModel> songs;
  List<UserModel> visitUser;
  List<ImageModel> imageList = [];
  List<SongModel> allSongsList = [];
  List<UserModel> allUsersList = [];
  List<Meme> memesList;
  String returnedID;
  String tempSongUrl;
  String playerId = "";
  var idController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  List<Message> unreadMessage;
  HomepageState(this.user) {
    controller = HomepageController(this, this.timerService, this.touchService,
        this.limitService, this.allSongsList);
    controller.setupTimer();
    controller.setupTouchCounter();
    controller.getLimits();
    controller.thoughts();
    controller.getUnreadMessages();
  }

  /* //duplicate from controller
  gotoProfile(String uid) async {
    UserModel visitUser = await userService.readUser(uid);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ProfilePage(user, visitUser, true)));
  }
*/
  void stateChanged(Function f) {
    setState(f);
  }
  
  @override
  Widget build(BuildContext context) {
    this.context = context;
     if (music == false || leave == true) {
      play = false;
      pause = true;
      playerId = "";
      tempSongUrl = null;
      if (controller.audioPlayer != null) {
        controller.audioPlayer.stop();
        controller.audioPlayer.release();
        //print("PLAYER DEACTIVATED");
      } else {
        controller.audioPlayer.stop();
        controller.audioPlayer.release();
        controller.audioPlayer = null;
        tempSongUrl = null;
      }
      setState(() {
        leave = false;
      });
    } else {}
    if(globals.callState){
      // print("====global true");
      } else {
      // print("====global false");
      controller.setUpCheckCall(this.context);
    }
    

    var childButtons = List<UnicornButton>();
    final IconButton messageIcon = IconButton(
      icon: Icon(Icons.textsms),
      iconSize: 25,
      onPressed: controller.mainChatScreen,
      color: DesignConstants.yellow,
    );
    childButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "Add Thoughts",
        labelFontSize: 10,
        currentButton: FloatingActionButton(
          heroTag: "Add Thoughts",
          backgroundColor: Colors.white,
          mini: true,
          child: Icon(
            Icons.bubble_chart,
            color: Colors.black,
          ),
          onPressed: controller.addThought,
        ),
      ),
    );

    childButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "Add Photos",
        labelFontSize: 10,
        currentButton: FloatingActionButton(
          heroTag: "Add Photos",
          backgroundColor: Colors.white,
          mini: true,
          child: Icon(
            Icons.camera,
            color: Colors.black,
          ),
          onPressed: controller.addPhotos,
        ),
      ),
    );

    childButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "Add Memes",
        labelFontSize: 10,
        currentButton: FloatingActionButton(
          heroTag: "Add Memes",
          backgroundColor: Colors.white,
          mini: true,
          child: Icon(
            Icons.mood,
            color: Colors.black,
          ),
          onPressed: controller.navigateToMemes,
        ),
      ),
    );

    childButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "Add Music",
        labelFontSize: 10,
        currentButton: FloatingActionButton(
          heroTag: "Add Music",
          backgroundColor: Colors.white,
          mini: true,
          child: Icon(
            Icons.music_note,
            color: Colors.black,
          ),
          onPressed: controller.addMusic,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: music ? Colors.black : Colors.white,
      floatingActionButton: UnicornDialer(
        backgroundColor: Colors.transparent,
        parentButtonBackground: Colors.blueGrey[300],
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(
          Icons.add,
        ),
        childButtons: childButtons,
      ),
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: DesignConstants.blue,
        actions: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: controller.newContent,
                icon: Icon(
                  Icons.public,
                  size: 25,
                ),
                color: DesignConstants.yellow,
              ),
              IconButton(
                onPressed: controller.searchContent,
                icon: Icon(
                  Icons.search,
                  size: 25,
                ),
                color: DesignConstants.yellow,
              ),
              //=======
              Stack(
                children: <Widget>[
                  messageIcon,
                  Container(
                    width: 15,
                    height: 15,
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(top: 5),
                    child: Container(
                        width: 80,
                        height: 25,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.unreadMessages == null
                                ? DesignConstants.blue
                                : Colors.red,
                            border: Border.all(color: Colors.white, width: 1)),
                        child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: controller.unreadMessages == null
                                ? Center(child: Text('0'))
                                : Center(
                                    child: Text(
                                        controller.unreadMessages.length
                                            .toString(),
                                        style: TextStyle(fontSize: 8)),
                                  ))),
                  )
                ],
              ),

              //=======

              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: myFriendsRequest,
                color: DesignConstants.yellow,
              ),
            ],
          ),
        ],
      ),
      drawer: MyDrawer(context, user),
      body: thoughts
          ? ListView.builder(
              itemCount: friendsThoughtsList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    padding: EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                    decoration: BoxDecoration(
                      color: music ? Colors.black : Color(0xFFFFFFFF),
                      border: Border.all(
                        color: DesignConstants.blue,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ListTile(
                      title: FlatButton.icon(
                          onPressed: () {
                            controller.gotoProfile(
                                friendsThoughtsList.elementAt(index).uid);
                          },
                          icon: friendsThoughtsList
                                      .elementAt(index)
                                      .profilePic !=
                                  ''
                              ? Builder(builder: (BuildContext context) {
                                  try {
                                    return Container(
                                        width: 35,
                                        height: 35,
                                        child: Image.network(friendsThoughtsList
                                            .elementAt(index)
                                            .profilePic));
                                  } on PlatformException {
                                    return Icon(Icons.error_outline);
                                  }
                                })
                              : Icon(Icons.error_outline),
                          label: Expanded(
                            child: Text(
                              friendsThoughtsList.elementAt(index).email +
                                  ' ' +
                                  friendsThoughtsList
                                      .elementAt(index)
                                      .timestamp
                                      .toLocal()
                                      .toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            friendsThoughtsList.elementAt(index).text,
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                      trailing: EmojiContainer(
                        this.context,
                        this.user,
                        mediaTypes.thought.index,
                        friendsThoughtsList[index].thoughtId,
                        friendsThoughtsList[index].uid,
                      ),
                    ),
                  ),
                );
              },
            )
          : (meme
              ? ListView.builder(
                  itemCount: memesList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            onTap: () {
                              controller.gotoProfile(memesList[index].ownerID);
                            },
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  memesList[index].ownerPic),
                              backgroundColor: Colors.grey,
                            ),
                            title: GestureDetector(
                                child: Text(memesList[index].email),
                                onTap: () {}),
                            subtitle: Text(
                                DateFormat("MMM dd-yyyy 'at' HH:mm:ss")
                                    .format(memesList[index].timestamp)),
                            trailing: EmojiContainer(
                              this.context,
                              this.user,
                              mediaTypes.meme.index,
                              memesList[index].memeId,
                              memesList[index].ownerID,
                            ),
                          ),
                          Container(
                            child: CachedNetworkImage(
                              imageUrl: memesList[index].imgUrl,
                              fit: BoxFit.fitWidth,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error_outline),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : snapshots
                  ? ListView.builder(
                      itemCount: imageList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                onTap: () {
                                  controller
                                      .gotoProfile(imageList[index].ownerID);
                                },
                                leading:
                                    imageList[index].ownerPic.contains('http')
                                        ? CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                              imageList[index].ownerPic,
                                            ),
                                            backgroundColor: Colors.grey,
                                          )
                                        : Icon(Icons.error_outline),
                                title: GestureDetector(
                                    child: Text(imageList[index].createdBy),
                                    onTap: () {}),
                                subtitle: Text(DateFormat(
                                        "MMM dd-yyyy 'at' HH:mm:ss")
                                    .format(imageList[index].lastUpdatedAt)),
                                trailing: EmojiContainer(
                                  this.context,
                                  this.user,
                                  mediaTypes.snapshot.index,
                                  imageList[index].imageId,
                                  imageList[index].ownerID,
                                ),
                              ),
                              Container(
                                child: CachedNetworkImage(
                                  imageUrl: imageList[index].imageURL,
                                  fit: BoxFit.fitWidth,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error_outline),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : music
                      ? ListView.builder(
                          itemCount: allSongsList.length,
                          itemBuilder: (context, index) => Container(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 20,
                                  ),
                                  //for (UserModel users in allUserList)
                                  for (UserModel users in allUsersList)
                                    Container(
                                      child:
                                          allSongsList[index].createdBy ==
                                                  users.email
                                              ? Container(
                                                  child: Container(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Container(
                                                          child: Column(
                                                            children: <Widget>[
                                                              users.profilePic
                                                                      .isNotEmpty
                                                                  ? users.uid ==
                                                                          user
                                                                              .uid
                                                                      ? FlatButton(
                                                                          child:
                                                                              CircleAvatar(
                                                                            backgroundImage:
                                                                                NetworkImage(users.profilePic),
                                                                            radius:
                                                                                22.0,
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              visit = false;
                                                                            });
                                                                            controller.gotoProfile(user.uid);
                                                                          },
                                                                        )
                                                                      : FlatButton(
                                                                          child:
                                                                              CircleAvatar(
                                                                            backgroundImage:
                                                                                NetworkImage(users.profilePic),
                                                                            radius:
                                                                                22.0,
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              visit = true;
                                                                            });
                                                                            controller.gotoProfile(users.uid);
                                                                          },
                                                                        )
                                                                  : users.uid ==
                                                                          user.uid
                                                                      ? FlatButton(
                                                                          child:
                                                                              CircleAvatar(
                                                                            backgroundImage:
                                                                                NetworkImage(DesignConstants.profile),
                                                                            radius:
                                                                                22.0,
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              visit = false;
                                                                            });
                                                                            controller.gotoProfile(user.uid);
                                                                          },
                                                                        )
                                                                      : FlatButton(
                                                                          child:
                                                                              CircleAvatar(
                                                                            backgroundImage:
                                                                                NetworkImage(DesignConstants.profile),
                                                                            radius:
                                                                                22.0,
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              visit = true;
                                                                            });
                                                                            controller.gotoProfile(users.uid);
                                                                          },
                                                                        )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Column(
                                                            children: <Widget>[
                                                              Row(
                                                                children: <
                                                                    Widget>[
                                                                  users.username
                                                                          .isNotEmpty
                                                                      ? Container(
                                                                          child:
                                                                              Text(
                                                                            '${users.username}',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Container(
                                                                          child:
                                                                              Text(
                                                                            'Username Unavailable',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    '${allSongsList[index].genre}',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          11,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        EmojiContainer(
                                                          this.context,
                                                          this.user,
                                                          mediaTypes.music.index,
                                                          allSongsList[index].songId,
                                                          users.uid,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                    ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          '${allSongsList[index].title}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.blueGrey[100],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    child: ConstrainedBox(
                                      constraints:
                                          BoxConstraints.expand(height: 300),
                                      child: FlatButton(
                                        onPressed: () {
                                         play == false && pause == true
                                              ? setState(() {
                                                  controller.playFunc(
                                                    allSongsList[index].songURL,
                                                  );
                                                })
                                              : setState(() {
                                                  controller.pauseFunc(
                                                    allSongsList[index].songURL,
                                                  );
                                                });
                                        },
                                        padding: EdgeInsets.all(0.0),
                                        child: CachedNetworkImage(
                                          imageUrl: allSongsList[index].artWork,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error_outline),
                                        ),
                                      ),
                                    ),
                                  ),
                                  for (UserModel users in allUsersList)
                                    Container(
                                      child: allSongsList[index].createdBy ==
                                              users.email
                                          ? Container(
                                              padding: EdgeInsets.only(
                                                left: 22.0,
                                                top: 10.0,
                                              ),
                                              child: users.username.isNotEmpty
                                                  ? Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(
                                                            '${users.username}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(
                                                              'Username Unavailable'),
                                                        ],
                                                      ),
                                                    ),
                                            )
                                          : Container(),
                                    ),
                                  Container(
                                    padding: EdgeInsets.only(left: 22),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                            '${allSongsList[index].lastUpdatedAt}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ))
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : null),
      bottomNavigationBar: BottomAppBar(
        color: music ? Colors.black : Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text(
                'Thoughts',
                style: TextStyle(color: DesignConstants.yellow),
              ),
              onPressed: controller.thoughts,
              color:
                  thoughts ? DesignConstants.blueLight : DesignConstants.blue,
            ),
            RaisedButton(
              child: Text(
                'Memes',
                style: TextStyle(color: DesignConstants.yellow),
              ),
              onPressed: controller.meme,
              color: meme ? DesignConstants.blueLight : DesignConstants.blue,
            ),
            RaisedButton(
              child: Text(
                'SnapShots',
                style: TextStyle(color: DesignConstants.yellow),
              ),
              onPressed: controller.snapshots,
              color:
                  snapshots ? DesignConstants.blueLight : DesignConstants.blue,
            ),
            RaisedButton(
              child: Text(
                'Music',
                style: TextStyle(color: DesignConstants.yellow),
              ),
              onPressed: controller.music,
              color: music ? DesignConstants.blueLight : DesignConstants.blue,
            ),
          ],
        ),
      ),
    );
  }

  void myFriendsRequest() async {
   
    List<FriendRequests> friendRequests =
        await friendService.getFriendRequests(user.friendRequestRecieved);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotificationPage(user, friendRequests)));
  }
}
