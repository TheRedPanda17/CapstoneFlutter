import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simso/controller/homepage-controller.dart';
import 'package:simso/model/entities/user-model.dart';
import 'package:simso/view/homepage.dart';
import 'package:simso/view/login-page.dart';
import 'package:simso/view/time-management-page.dart';

import 'design-constants.dart';

class MyDrawer extends StatelessWidget {
  final UserModel user;
  final BuildContext context;
  final HomepageController controller;
  
  MyDrawer(this.context, this.user, this.controller);


  void navigateHomepage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Homepage(user)));
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

          Card(
            child: ListTile(
              leading: Icon(Icons.bubble_chart),
              title: Text('My Thoughts'),
              onTap: navigateHomepage,
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.group),
              title: Text('Friends'),
              onTap: navigateHomepage,
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.group_add),
              title: Text('Recommended Friends'),
              onTap: controller.recommendFriends,
            ),

          ),
           ListTile(
            leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: signOut,
              ),    //Special Widget for Drawer
        ],
      ),
    );
  }
}
