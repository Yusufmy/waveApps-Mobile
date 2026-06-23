import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../config/zego_config.dart';
import '../modules/ChatScreen/ChatDetailScreen/CallDetailScreen/controllers/call_detail_screen_controller.dart'
    show CallDetailScreenController;

class ZegoCallService {
  static final ZegoCallService instance = ZegoCallService._();
  ZegoCallService._();

  bool _initialized = false;
  bool isJoinedRoom = false;

  Future<void> init() async {
    if (_initialized) return;

    await ZegoExpressEngine.createEngineWithProfile(
      ZegoEngineProfile(
        ZegoConfig.appID,
        ZegoScenario.General,
        appSign: ZegoConfig.appSign,
      ),
    );

    setupListeners();

    _initialized = true;
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

              try {
                final controller = Get.find<CallDetailScreenController>();

                await ZegoExpressEngine.instance.startPlayingStream(
                  stream.streamID,
                  canvas: ZegoCanvas(controller.remoteViewID.value),
                );
                // await ZegoExpressEngine.instance.startPlayingStream(
                //   stream.streamID,
                // );

                print("REMOTE STREAM => ${stream.streamID}");

                /// Nanti jika video sudah memakai canvas
                /// tambahkan createCanvasView di sini
                ///
                /// await ZegoExpressEngine.instance.createCanvasView(
                ///   (viewID) async {
                ///     remoteViewID.value = viewID;
                ///
                ///     await ZegoExpressEngine.instance.startPlayingStream(
                ///       stream.streamID,
                ///       canvas: ZegoCanvas(viewID),
                ///     );
                ///   },
                /// );
              } catch (e) {
                print("GAGAL PLAY STREAM => ${stream.streamID} ERROR => $e");
              }
            }
          }

          if (updateType == ZegoUpdateType.Delete) {
            for (final stream in streamList) {
              print("STREAM REMOVED => ${stream.streamID}");
            }
          }
        };

    ZegoExpressEngine.onRoomStateChanged =
        (roomID, reason, errorCode, extendedData) {
          print(
            "ROOM STATE => room=$roomID "
            "reason=$reason "
            "error=$errorCode",
          );
        };

    ZegoExpressEngine.onRoomOnlineUserCountUpdate = (roomID, count) {
      print(
        "=== ONLINE USER COUNT === "
        "roomID: $roomID, count: $count",
      );
    };

    ZegoExpressEngine.onPublisherStateUpdate =
        (streamID, state, errorCode, extendedData) {
          print(
            "PUBLISH STATE => "
            "stream=$streamID "
            "state=$state "
            "error=$errorCode",
          );
        };

    ZegoExpressEngine.onPublisherCapturedAudioFirstFrame = () {
      print("MIC AUDIO FIRST FRAME");
    };

    ZegoExpressEngine.onCapturedSoundLevelUpdate = (level) {
      print("LOCAL MIC LEVEL => $level");
    };

    ZegoExpressEngine.onRemoteSoundLevelUpdate = (map) {
      print("REMOTE LEVEL => $map");
    };

    /// Video listener
    ZegoExpressEngine.onPublisherCapturedVideoFirstFrame = (channel) {
      print("LOCAL VIDEO FIRST FRAME => $channel");
    };

    ZegoExpressEngine.onPlayerStateUpdate =
        (streamID, state, errorCode, extendedData) {
          print(
            "PLAYER STATE => "
            "stream=$streamID "
            "state=$state "
            "error=$errorCode",
          );
        };
  }

  Future<void> joinRoom({
    required String roomID,
    required String userID,
    required String userName,
    required String type,
  }) async {
    // Hapus permission check di sini, sudah di-handle di main.dart
    await init();

    final mic = await Permission.microphone.request();
    final camera = await Permission.camera.request();

    print("MIC STATUS => $mic");
    print("CAMERA STATUS => $camera");

    print("LOGIN ROOM => $roomID | userID: $userID");

    ZegoExpressEngine
        .onPublisherStateUpdate = (streamID, state, errorCode, extendedData) {
      print("PUBLISH STATE => stream=$streamID state=$state error=$errorCode");
    };

    ZegoExpressEngine.onPublisherCapturedAudioFirstFrame = () {
      print("MIC AUDIO FIRST FRAME");
    };

    ZegoExpressEngine.onRoomStateChanged =
        (roomID, reason, errorCode, extendedData) {
          print("ROOM STATE => room=$roomID reason=$reason error=$errorCode");
        };

    ZegoExpressEngine
        .onPublisherStateUpdate = (streamID, state, errorCode, extendedData) {
      print("PUBLISH STATE => stream=$streamID state=$state error=$errorCode");
    };

    await ZegoExpressEngine.instance.startSoundLevelMonitor();

    ZegoExpressEngine.onCapturedSoundLevelUpdate = (level) {
      print("LOCAL MIC LEVEL => $level");
    };

    ZegoExpressEngine.onRemoteSoundLevelUpdate = (map) {
      print("REMOTE LEVEL => $map");
    };

    if (type == "video") {
      final controller = Get.find<CallDetailScreenController>();

      await ZegoExpressEngine.instance.enableCamera(true);

      await ZegoExpressEngine.instance.startPreview(
        canvas: ZegoCanvas(controller.localViewID.value),
      );
      await ZegoExpressEngine.instance.enableAudioCaptureDevice(true);
    }

    print("START SOUND LEVEL MONITOR");

    ZegoExpressEngine.onRoomStateChanged =
        (roomID, reason, errorCode, extendedData) {
          print(
            "ROOM STATE => "
            "room=$roomID "
            "reason=$reason "
            "error=$errorCode",
          );
        };

    ZegoExpressEngine.onPublisherStateUpdate =
        (streamID, state, errorCode, extendedData) {
          print("========== PUBLISH ==========");
          print("STREAM : $streamID");
          print("STATE  : $state");
          print("ERROR  : $errorCode");
          print("DATA   : $extendedData");
        };
    await ZegoExpressEngine.instance.startSoundLevelMonitor();

    await ZegoExpressEngine.instance.loginRoom(
      roomID,
      ZegoUser(userID, userName),
      config: ZegoRoomConfig(0, true, ""),
    );

    await ZegoExpressEngine.instance.muteMicrophone(false);
    await ZegoExpressEngine.instance.muteSpeaker(false);
    await ZegoExpressEngine.instance.setAudioRouteToSpeaker(true);
    await ZegoExpressEngine.instance.enableAudioCaptureDevice(true);

    await ZegoExpressEngine.instance.muteMicrophone(false);

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
