import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wive_app/app/config/zego_config.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../modules/ChatScreen/ChatDetailScreen/CallDetailScreen/controllers/call_detail_screen_controller.dart';

class CallPage extends StatelessWidget {
  final String roomID;
  final String userID;
  final String userName;

  const CallPage({
    Key? key,
    required this.roomID,
    required this.userID,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: ZegoConfig.appID,
      appSign: ZegoConfig.appSign,
      userID: userID,
      userName: userName,
      callID: roomID,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (event, defaultAction) {
          final controller = Get.find<CallDetailScreenController>();
          final callId = controller.callData["_resolvedCallId"];

          if (event.reason == ZegoUIKitCallEndReason.localHangUp) {
            controller.endtCall(callId);
          }

          defaultAction.call();
        },
      ),
    );
  }
}
