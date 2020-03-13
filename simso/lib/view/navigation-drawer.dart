import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import '../service-locator.dart';
//model imports
import '../model/entities/globals.dart' as globals;
import '../model/entities/local-user.dart';
import '../model/entities/friend-model.dart';
import '../model/entities/user-model.dart';
import '../model/entities/thought-model.dart';
import '../model/entities/dictionary-word-model.dart';
import '../model/services/ifriend-service.dart';
import '../model/services/ithought-service.dart';
import '../model/entities/song-model.dart';
import '../model/services/isong-service.dart';
import '../model/services/idictionary-service.dart';
//view imports
import '../view/friends-page.dart';
import '../view/homepage.dart';
import '../view/my-thoughts-page.dart';
import '../view/login-page.dart';
import '../view/recommend-friends-page.dart';
import '../view/time-management-page.dart';
import '../view/design-constants.dart';
import '../view/snapshot-page.dart';
import '../view/meme-page.dart';
import '../view/account-setting-page.dart';
import '../view/my-music-page.dart';
//controller import

class MyDrawer extends StatelessWidget {
  final UserModel user;
  final BuildContext context;
  final LocalUser localUserFunction = LocalUser();
  final IFriendService friendService = locator<IFriendService>();
  final ISongService _songService = locator<ISongService>();
  final IThoughtService _thoughtService = locator<IThoughtService>();
  final IDictionaryService _dictionaryService = locator<IDictionaryService>();

  MyDrawer(this.context, this.user);

  void navigateHomepage() {
    List<SongModel> songlist;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Homepage(
                  user,
                  songlist,
                )));
  }

  void navigateSnapshotPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SnapshotPage()));
  }

  void navigateMemePage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MemePage()));
  }

  void navigateAccountSettingPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AccountSettingPage()));
  }

  void navigateMyThoughts() async {
    List<Thought> myThoughtsList =
        await _thoughtService.getThoughts(user.uid.toString());
    
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyThoughtsPage(user, myThoughtsList)));
  }

  void signOut() async {
    String readInData = await localUserFunction.readLocalUser();
    String credential = await localUserFunction.readCredential();
    int i = readInData.indexOf(' ');
    user.email = readInData.substring(0,i);
    user.password= readInData.substring(i+1);
    FirebaseAuth.instance.signOut();    //Email/pass sign out
    GoogleSignIn().signOut();
    //Display confirmation dialog box after user clicking on "Sign Out" button
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmation',
            style: TextStyle(color: DesignConstants.yellow, fontSize: 30),
          ),
          content: Text('Would you like to sign out?',
              style: TextStyle(color: DesignConstants.yellow)),
          backgroundColor: DesignConstants.blue,
          actions: <Widget>[
            RaisedButton(
              child: Text(
                'YES',
                style: TextStyle(color: DesignConstants.yellow, fontSize: 20),
              ),
              color: DesignConstants.blue,
              onPressed: () {
                //Dialog box pop up to confirm signing out
                FirebaseAuth.instance.signOut();
                globals.timer.stopTimer();
                globals.timer = null;
                globals.touchCounter = null;
                globals.limit = null;
                //Close Drawer, then go back to Front Page
                Navigator.pop(context);  //Close Dialog box
                Navigator.pop(context);  //Close Drawer
                //Navigator.pop(state.context);  //Close Home Page 
                Navigator.push(context, MaterialPageRoute(
                  builder: (context)=> LoginPage(
                    localUserFunction: localUserFunction, 
                    credential: credential=='true'? credential: null,
                    email: credential=='true'? user.email: null,
                    password: credential=="true"? user.password: null,
                    ),
                ));
              },
            ),
            RaisedButton(
              child: Text(
                'NO',
                style: TextStyle(color: DesignConstants.yellow, fontSize: 20),
              ),
              color: DesignConstants.blue,
              onPressed: () => Navigator.pop(context), //close dialog box
            ),
          ],
        );
      },
    );
  }

  void myFriendsMenu() async {
    List<Friend> friends = await friendService.getFriends(user.friends);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => FriendPage(user, friends)));
  }

  void recommendFriends() async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecommendFriends(user),
        ));
  }

  void navigateTimeManagement() async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => TimeManagementPage(user)));
  }

  void navigateMyMusic() async {
    List<SongModel> songlist;
    try {
      print("GET SONGS");
      songlist = await _songService.getSong(user.email);
    } catch (e) {
      songlist = <SongModel>[];
      print("SONGLIST LENGTH: " + songlist.length.toString());
    }
    print("SUCCEED IN GETTING SONGS");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyMusic(user, songlist),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: DesignConstants.blue),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.profilePic != null && user.profilePic != ''
                      ? user.profilePic
                      : DesignConstants.profile,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.account_circle),
                ),
              ),
            ),
            accountName: Text(user.username),
            accountEmail: Text(user.email),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Homepage'),
            onTap: navigateHomepage,
          ),
          ListTile(
            leading: Icon(Icons.timer),
            title: Text('Time Management'),
            onTap: navigateTimeManagement,
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Friends'),
            onTap: myFriendsMenu,
          ),
          ListTile(
            leading: Icon(Icons.group_add),
            title: Text('Recommended Friends'),
            onTap: recommendFriends,
          ),
          ListTile(
            leading: Icon(Icons.music_note),
            title: Text('My Music'),
            onTap: navigateMyMusic,
          ),
          ListTile(
            leading: Icon(Icons.camera),
            title: Text('My Snapshots'),
            onTap: navigateSnapshotPage,
          ),
          ListTile(
            leading: Icon(Icons.mood),
            title: Text('My Memes'),
            onTap: navigateMemePage,
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Account Settings'),
            onTap: navigateAccountSettingPage,
          ),
          ListTile(
            leading: Icon(Icons.bubble_chart),
            title: Text('My Thoughts'),
            onTap: navigateMyThoughts,
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sign Out'),
            onTap: signOut,
          ), //Special Widget for Drawer
        ],
      ),
    );
  }
}
