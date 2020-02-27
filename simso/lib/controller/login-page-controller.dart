import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simso/model/entities/local-user.dart';
import 'package:simso/model/services/iuser-service.dart';
import 'package:simso/view/create-account.dart';
import 'package:simso/view/homepage.dart';
import 'package:simso/view/login-page.dart';
import 'package:simso/view/mydialog.dart';

class LoginPageController{
  LoginPageState state;
  IUserService userService;
  final LocalUser localUser;
  
  LoginPageController(this.state, this.userService, this.localUser);

  void goToHomepage() async{
    if(!state.formKey.currentState.validate()){
      return;
    }
    state.formKey.currentState.save();
    MyDialog.showProgressBar(state.context);
    try{
      state.user.uid = await userService.login(state.user);
      if (state.user.uid!=''||state.user.uid!=null){
        state.user = await userService.readUser(state.user.uid);
        state.stateChanged((){});
      }
    }
    catch(error){
       MyDialog.popProgressBar(state.context);
      MyDialog.info(
        
        context: state.context,
        title: 'Login Error',
        message: 'Invalid username or password! \nTry again!',
        action: () => Navigator.pop(state.context),
      );
        return;  //Do not proceed if log in failed
    }
    if (state.user.uid!=null|| state.user.uid !=''){
      MyDialog.popProgressBar(state.context);
      Navigator.push(state.context,MaterialPageRoute(
      builder: (context) => Homepage(state.user),
      ));
    }
    else return null;
    //need to send message of success or failure. need to create a load in progress indicator.
  }

  String validateEmail(String value) {
    if (!(value.contains('@') || value.contains('.'))){
      return '  Invalid email format. \n  Must contain @ and . \n  Also no empty spaces.';
    }
    return null;
  }

  void saveEmail(String newValue) {
    newValue = newValue.replaceAll(' ', '');
    state.user.email = newValue.replaceAll(String.fromCharCode(newValue.length-1), '');
  }

  String validatePassword(String value) {
    if (value.length <= 5){
      return '  Please enter at least 6 characters.';
    }
    return null;
  }

  void savePassword(String newValue) {
    state.user.password = newValue;
  }

  void createAccount() {
    Navigator.push(state.context,MaterialPageRoute(
      builder: (context) => CreateAccount(),
      ));
  }

  void entry(String value) {
    if (value!=null){
      state.entry = true;
    }
    if (value=='') state.entry = false;
    state.stateChanged((){});
  }

  Future<void> checkBiometric() async {
    try{
      // state.checkBiometric = await state.bioAuth.canCheckBiometrics;
      // print(state.checkBiometric);
      state.readLocalUser();
      state.biometricList = await state.bioAuth.getAvailableBiometrics();
      if(state.biometricList.length<1) {
        MyDialog.info(
          context: state.context, 
          title: 'Biometric Authentication Error', 
          message: state.readInData!=null?'No Biometric hardware available'
            :
            'You need to setup/link your fingerprint to an account!', 
          action: (){Navigator.pop(state.context);});
      }
      else
      // state.checkBiometric = false;
      {
        state.checkBiometric = await state.bioAuth.authenticateWithBiometrics(
        localizedReason: 'Checking Fingerprint',
        useErrorDialogs: true,
        stickyAuth: true);
        if (state.checkBiometric) {
          // state.localuser();
          state.readLocalUser();
          print(state.readInData);
          int i = state.readInData.indexOf(' ');
          state.user.email = state.readInData.substring(0,i);
          state.user.password=state.readInData.substring(i+1);
          if (state.user.email!=''&&state.user.password!=''){
            userService.login(state.user)
              .then((value) => 
                Navigator.push(state.context, MaterialPageRoute(
                  builder: (context)=>Homepage(state.user))),
            );
          }
    
        }
      }
      print(state.checkBiometric);
    }
    catch(error){
      print(error);
    }
  }
}