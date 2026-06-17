import 'package:permission_handler/permission_handler.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../config/zego_config.dart';

class ZegoCallService {
  static final ZegoCallService instance = ZegoCallService._();
  ZegoCallService._();

  bool _initialized = false;
  bool isJoinedRoom = false;

  Future<void> init() async {
    // if (_initialized) return;

    await ZegoExpressEngine.createEngineWithProfile(
      ZegoEngineProfile(
        ZegoConfig.appID,
        ZegoScenario.General,
        appSign: ZegoConfig.appSign,
      ),
    );

    setupListeners();

    // _initialized = true;
  }

  // Pisahkan setup listener dari init
  void setupListeners() {
    ZegoExpressEngine.onRoomStreamUpdate =
        (roomID, updateType, streamList, extendedData) async {
          print("========== STREAM UPDATE ==========");
          print("ROOM ID : $roomID");
          print("UPDATE TYPE : $updateType");
          print("STREAM COUNT : ${streamList.length}");

          for (final stream in streamList) {
            print("STREAM DETECTED => ${stream.streamID}");
          }

          if (updateType == ZegoUpdateType.Add) {
            for (final stream in streamList) {
              print("START PLAYING => ${stream.streamID}");

              await ZegoExpressEngine.instance.startPlayingStream(
                stream.streamID,
              );
            }
          }
        };

    ZegoExpressEngine.onRoomStateChanged =
        (roomID, reason, errorCode, extendedData) {
          print("ROOM STATE => $roomID | reason: $reason | error: $errorCode");
        };

    ZegoExpressEngine.onRoomOnlineUserCountUpdate = (roomID, count) {
      print("=== ONLINE USER COUNT === roomID: $roomID, count: $count");
    };
  }

  Future<void> joinRoom({
    required String roomID,
    required String userID,
    required String userName,
  }) async {
    // Hapus permission check di sini, sudah di-handle di main.dart
    await init();

    print("LOGIN ROOM => $roomID | userID: $userID");

    await ZegoExpressEngine.instance.loginRoom(
      roomID,
      ZegoUser(userID, userName),
      config: ZegoRoomConfig(0, true, ""),
    );

    await ZegoExpressEngine.instance.muteMicrophone(false);
    await ZegoExpressEngine.instance.muteSpeaker(false);
    await ZegoExpressEngine.instance.setAudioRouteToSpeaker(true);
    await ZegoExpressEngine.instance.startPublishingStream("stream_$userID");

    isJoinedRoom = true;
  }

  Future<void> leaveRoom(String roomID) async {
    if (!isJoinedRoom) {
      print("Belum join room, skip leaveRoom");
      return;
    }

    await ZegoExpressEngine.instance.stopPublishingStream();
    await ZegoExpressEngine.instance.logoutRoom(roomID);

    isJoinedRoom = false;
  }

  Future<void> destroyEngine() async {
    if (!_initialized) return;
    await ZegoExpressEngine.destroyEngine();
    _initialized = false;
    isJoinedRoom = false;
  }
}
