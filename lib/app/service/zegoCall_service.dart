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
  String? _currentUserID;

  Future<void> init() async {
    print("=== ZEGO INIT === _initialized=$_initialized");

    if (_initialized) {
      print("SKIP INIT — sudah initialized");
      setupListeners();
      return;
    }

    await ZegoExpressEngine.createEngineWithProfile(
      ZegoEngineProfile(
        ZegoConfig.appID,
        ZegoScenario.Communication,
        appSign: ZegoConfig.appSign,
      ),
    );

    setupListeners();
    _initialized = true;
    print("ZEGO INIT DONE");
  }

  void setupListeners() {
    ZegoExpressEngine.onRoomStreamUpdate =
        (roomID, updateType, streamList, extendedData) async {
          if (updateType == ZegoUpdateType.Add) {
            for (final stream in streamList) {
              try {
                final controller = Get.find<CallDetailScreenController>();

                int retry = 0;
                while (controller.remoteViewID.value == -1 && retry < 30) {
                  print("Tunggu remoteViewID siap... retry=$retry");
                  await Future.delayed(const Duration(milliseconds: 100));
                  retry++;
                }

                if (controller.remoteViewID.value == -1) {
                  print("REMOTE VIEW MASIH -1 SETELAH RETRY, SKIP");
                  return;
                }

                print("=== AKAN PLAY STREAM ===");
                print("streamID     = ${stream.streamID}");
                print("remoteViewID = ${controller.remoteViewID.value}");
                print("localViewID  = ${controller.localViewID.value}");

                await ZegoExpressEngine.instance.startPlayingStream(
                  stream.streamID,
                  canvas: ZegoCanvas(
                    controller.remoteViewID.value,
                    viewMode: ZegoViewMode.AspectFill,
                  ),
                );

                print("PLAY STREAM SUCCESS");
              } catch (e) {
                print("GAGAL PLAY STREAM => $e");
              }
            }
          }

          if (updateType == ZegoUpdateType.Delete) {
            for (final stream in streamList) {
              await ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
              print("STOP PLAY STREAM => ${stream.streamID}");
            }
          }
        };

    ZegoExpressEngine.onRoomStateChanged =
        (roomID, reason, errorCode, extendedData) {
          print("ROOM STATE => room=$roomID reason=$reason error=$errorCode");
        };

    ZegoExpressEngine.onRoomOnlineUserCountUpdate = (roomID, count) {
      print("=== ONLINE USER COUNT === roomID: $roomID, count: $count");
    };

    ZegoExpressEngine.onPublisherStateUpdate =
        (streamID, state, errorCode, extendedData) {
          print("PUBLISH STATE => stream=$streamID state=$state error=$errorCode");
        };

    ZegoExpressEngine.onPublisherCapturedAudioFirstFrame = () {
      print("MIC AUDIO FIRST FRAME");
    };

    ZegoExpressEngine.onPublisherCapturedVideoFirstFrame = (channel) {
      print("LOCAL VIDEO FIRST FRAME => $channel");
    };

    ZegoExpressEngine.onPlayerStateUpdate =
        (streamID, state, errorCode, extendedData) {
          print("PLAYER STATE => stream=$streamID state=$state error=$errorCode");
        };

    ZegoExpressEngine.onCapturedSoundLevelUpdate = (level) {
      print("LOCAL MIC LEVEL => $level");
    };

    ZegoExpressEngine.onRemoteSoundLevelUpdate = (map) {
      print("REMOTE LEVEL => $map");
    };
  }

  Future<void> joinRoom({
    required String roomID,
    required String userID,
    required String userName,
    required String type,
  }) async {
    // Jangan panggil init() lagi di sini — sudah dipanggil sebelum createVideoViews
    _currentUserID = userID;

    final mic = await Permission.microphone.request();
    final camera = await Permission.camera.request();
    print("MIC STATUS => $mic");
    print("CAMERA STATUS => $camera");
    print("LOGIN ROOM => $roomID");

    await ZegoExpressEngine.instance.enableAudioCaptureDevice(true);
    await ZegoExpressEngine.instance.muteMicrophone(false);
    await ZegoExpressEngine.instance.muteSpeaker(false);
    await ZegoExpressEngine.instance.setAudioRouteToSpeaker(true);
    await ZegoExpressEngine.instance.startSoundLevelMonitor();

    if (type == "video") {
      final controller = Get.find<CallDetailScreenController>();

      await ZegoExpressEngine.instance.enableCamera(true);
      await ZegoExpressEngine.instance.useFrontCamera(true);

      // FIX: setVideoConfig harus benar-benar dipanggil
      await ZegoExpressEngine.instance.setVideoConfig(
        ZegoVideoConfig(240, 320, 240, 320, 15, 300, ZegoVideoCodecID.Default),
      );

      if (controller.localViewID.value != -1) {
        print("START PREVIEW => localViewID=${controller.localViewID.value}");
        await ZegoExpressEngine.instance.startPreview(
          canvas: ZegoCanvas(
            controller.localViewID.value,
            viewMode: ZegoViewMode.AspectFill,
          ),
        );
      } else {
        print("LOCAL VIEW -1, SKIP PREVIEW");
      }
    }

    await ZegoExpressEngine.instance.loginRoom(
      roomID,
      ZegoUser(userID, userName),
      config: ZegoRoomConfig(0, true, ""),
    );

    await ZegoExpressEngine.instance.startPublishingStream("stream_$userID");

    isJoinedRoom = true;
    print("JOIN ROOM SUCCESS => $roomID");
  }

  Future<void> leaveRoom(String roomID) async {
    if (!isJoinedRoom) {
      print("Belum join room, skip leaveRoom");
      return;
    }

    try {
      await ZegoExpressEngine.instance.stopPreview();
      await ZegoExpressEngine.instance.stopPublishingStream();
      await ZegoExpressEngine.instance.logoutRoom(roomID);
    } catch (e) {
      print("LEAVE ROOM ERROR => $e");
    }

    isJoinedRoom = false;
    _currentUserID = null;
    print("LEAVE ROOM SUCCESS => $roomID");
  }

  Future<void> destroyEngine() async {
    if (!_initialized) return;
    try {
      await ZegoExpressEngine.destroyEngine();
    } catch (e) {
      print("DESTROY ENGINE ERROR => $e");
    }
    _initialized = false;
    isJoinedRoom = false;
    _currentUserID = null;
    print("ENGINE DESTROYED");
  }
}
