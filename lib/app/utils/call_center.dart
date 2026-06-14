// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// import '../config/zego_config.dart';

// class VoiceCallPage extends StatelessWidget {
//   final String roomID;
//   final String userID;
//   final String userName;

//   const VoiceCallPage({
//     super.key,
//     required this.roomID,
//     required this.userID,
//     required this.userName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     print("ROOM ID : $roomID");
//     print("USER ID : $userID");
//     print("USER NAME : $userName");

//     final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

//     config.pip.enableWhenAppBackToDesktop = false;

//     return ZegoUIKitPrebuiltCall(
//       appID: ZegoConfig.appID,
//       appSign: ZegoConfig.appSign,
//       userID: userID,
//       userName: userName,
//       callID: roomID,
//       config: config,
//     );
//   }
// }

// extension on ZegoCallPIPConfig {
//   set enableWhenAppBackToDesktop(bool enableWhenAppBackToDesktop) {}
// }
