import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/utils/api.dart';
import 'package:wive_app/app/utils/colors.dart';
import 'package:wive_app/app/utils/format.dart';

import '../modules/ChatScreen/ChatDetailScreen/controllers/chat_screen_chat_detail_screen_controller.dart';

class VoiceBubble extends StatefulWidget {
  final String audioUrl;
  final String duration;
  final bool isMe;
  final int time;
  final String status;

  const VoiceBubble({
    super.key,
    required this.audioUrl,
    required this.duration,
    required this.time,
    required this.status,
    this.isMe = false,
  });

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  final chatController = Get.find<ChatScreenChatDetailScreenController>();
  late final PlayerController _playerController;
  late final String _audioId;
  late final String
  _debugId; // ⬅️ id unik per State object, untuk lacak instance

  bool isPlaying = false;
  bool isLoading = true;

  static int _instanceCounter = 0; // ⬅️ hitung berapa kali State dibuat total
  bool _hasCompleted =
      false; // ⬅️ BARU: tandai kalau native session sudah completed/released

  void _log(String msg) {
    final ts = DateTime.now().toIso8601String().substring(11, 23);
    debugPrint(
      "🎙️[$ts][id=$_debugId][audio=${widget.audioUrl.split('/').last}][key=${widget.key}] $msg",
    );
  }

  Widget buildStatus(String status) {
    switch (status) {
      case "sending":
        return const Icon(Icons.access_time, size: 14, color: Colors.black87);

      case "sent":
        return const Icon(Icons.check, size: 14, color: Colors.black87);

      case "delivered":
        return const Icon(Icons.done_all, size: 14, color: Colors.black87);

      case "read":
        return const Icon(Icons.done_all, size: 14, color: Colors.blue);

      default:
        return const SizedBox();
    }
  }

  @override
  void initState() {
    super.initState();
    _instanceCounter++;
    _debugId = "S$_instanceCounter";
    _audioId = widget.audioUrl;

    _log("🟢 initState() dipanggil — instance ke-$_instanceCounter dibuat.");

    _playerController = PlayerController();
    _prepare();

    _playerController.onCompletion.listen((_) {
      _log("📻 onCompletion fired");
      _hasCompleted = true; // ⬅️ BARU

      // ⬅️ FIX Temuan 1: clear currentPlayingAudioId juga di sini
      if (chatController.currentPlayingAudioId.value == _audioId) {
        chatController.currentPlayingAudioId.value = null;
        _log("onCompletion: currentPlayingAudioId di-clear");
      }

      if (mounted) {
        setState(() => isPlaying = false);
      } else {
        _log("⚠️ onCompletion fired TAPI widget SUDAH tidak mounted!");
      }
    });

    _playerController.onPlayerStateChanged.listen((state) {
      _log("📻 onPlayerStateChanged -> $state (mounted=$mounted)");
      if (mounted) {
        setState(() => isPlaying = state == PlayerState.playing);
      }
    });
  }

  @override
  void didUpdateWidget(covariant VoiceBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    _log(
      "🔄 didUpdateWidget dipanggil. "
      "oldAudioUrl=${oldWidget.audioUrl.split('/').last}, "
      "newAudioUrl=${widget.audioUrl.split('/').last}, "
      "sameWidgetInstance=${identical(oldWidget, widget)}",
    );
    if (oldWidget.audioUrl != widget.audioUrl) {
      _log(
        "🚨 PERINGATAN: audioUrl BERUBAH di State yang SAMA! "
        "Ini akan bikin _playerController lama mengarah ke audio SALAH.",
      );
    }
  }

  Future<void> _prepare() async {
    _log("⏳ _prepare() MULAI — memanggil preparePlayer()...");
    final sw = Stopwatch()..start();
    try {
      final url = "${Api.publicUrl}storage/${widget.audioUrl}";
      await _playerController.preparePlayer(path: url);
      _log("✅ _prepare() SUKSES setelah ${sw.elapsedMilliseconds}ms");
    } catch (e, stack) {
      _log("❌ _prepare() GAGAL setelah ${sw.elapsedMilliseconds}ms: $e");
      _log("   stack: $stack");
    } finally {
      _log(
        "_prepare() finally — mounted=$mounted, akan setState isLoading=false",
      );
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> playPause() async {
    _log(
      "👆 playPause() DI-TAP. isLoading=$isLoading, isPlaying=$isPlaying, "
      "hasCompleted=$_hasCompleted, "
      "currentPlayingAudioId=${chatController.currentPlayingAudioId.value}",
    );

    if (isLoading) {
      _log("⏸️ Diabaikan karena masih isLoading=true");
      return;
    }

    try {
      if (chatController.currentPlayingAudioId.value != null &&
          chatController.currentPlayingAudioId.value != _audioId) {
        _log("🛑 Ada bubble lain sedang main, memanggil stopCurrentAudio()...");
        await chatController.stopCurrentAudio();
        _log("🛑 stopCurrentAudio() selesai");
      }

      if (isPlaying) {
        _log("⏸️ Memanggil pausePlayer()...");
        await _playerController.pausePlayer();
        _log("⏸️ pausePlayer() selesai");
        if (chatController.currentPlayingAudioId.value == _audioId) {
          chatController.currentPlayingAudioId.value = null;
        }
      } else {
        // ⬅️ FIX Temuan 2: kalau sudah pernah completed, seekTo(0) dulu
        if (_hasCompleted) {
          _log("⏮️ Lagu sudah pernah selesai, memanggil seekTo(0) dulu...");
          final sw = Stopwatch()..start();
          try {
            await _playerController.seekTo(0);
            _log("⏮️ seekTo(0) selesai (${sw.elapsedMilliseconds}ms)");
          } catch (e, stack) {
            _log("❌ seekTo(0) ERROR: $e");
            _log("   stack: $stack");
          }
          _hasCompleted = false;
        }

        _log("▶️ Memanggil startPlayer()...");
        final sw = Stopwatch()..start();
        await _playerController.startPlayer();
        _log("▶️ startPlayer() selesai (${sw.elapsedMilliseconds}ms)");
        chatController.currentPlayingAudioId.value = _audioId;
        chatController.registerActivePlayer(_audioId, _playerController);
      }
    } catch (e, stack) {
      _log("❌ playPause() ERROR: $e");
      _log("   stack: $stack");
    }
  }

  @override
  Widget build(BuildContext context) {
    _log("🏗️ build() dipanggil. isLoading=$isLoading, isPlaying=$isPlaying");

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: EdgeInsets.only(left: widget.isMe ? 0 : 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.isMe) ...[
                  GestureDetector(
                    onTap: playPause,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ] else ...[
                  Text(
                    "${widget.duration}s",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],

                const SizedBox(width: 8),
                Expanded(
                  child: AudioFileWaveforms(
                    playerController: _playerController,
                    size: const Size(double.infinity, 40),
                    playerWaveStyle: PlayerWaveStyle(
                      fixedWaveColor: Colors.grey,
                      liveWaveColor: AppColors.blueColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.isMe) ...[
                  Text(
                    "${widget.duration}s",
                    style: const TextStyle(fontSize: 12),
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: playPause,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formatChatTime(widget.time),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    // color: isMe ? Colors.white70 : Colors.black45,
                    color: Colors.black45,
                  ),
                ),
                if (widget.isMe == true) ...[
                  const SizedBox(width: 4),
                  // Image.asset(
                  //   "assets/images/doubleCheck.png",
                  //   width: 14,
                  //   height: 14,
                  //   color: Colors.blue,
                  // ),
                  buildStatus(widget.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
