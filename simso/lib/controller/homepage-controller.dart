
import 'package:simso/model/entities/user-model.dart';
import 'package:simso/model/services/itimer-service.dart';
import 'package:simso/model/services/iuser-service.dart';
import 'package:simso/view/homepage.dart';
import '../model/entities/globals.dart' as globals;

class HomepageController{
  
  HomepageState state;
  IUserService _userService;
  ITimerService _timerService;
  UserModel newUser = UserModel();
  String userID;

  HomepageController(this.state, this._userService, this._timerService);

  void setupTimer() async {
    var timer = await _timerService.getTimer(state.user.docID, 0);
    if (timer == null){
      timer = await _timerService.createTimer(state.user.docID);
    }
    
    globals.timer = timer;
    globals.timer.startTimer();
  }

  void getUserData() async {
    state.formKey.currentState.save();
    state.user = await _userService.getUserDataByID(userID);
    state.stateChanged(() => {});
  }

  void saveUser() async {
    state.formKey.currentState.save();
    state.returnedID = await _userService.saveUser(newUser);
    state.idController.text = state.returnedID;
    state.stateChanged(() => {});
    print(state.returnedID);
  }

  void saveEmail(String value) {
    newUser.email = value;
  }

  void saveUsername(String value) {
    newUser.username = value;
  }

  void saveUserID(String value) {
    userID = value;
  }

  void refreshState() {
    state.stateChanged(() => {});
  }
}