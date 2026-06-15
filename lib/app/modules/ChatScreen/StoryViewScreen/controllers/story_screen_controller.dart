import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:wive_app/app/utils/api.dart';

class StoryScreenController extends GetxController {
  RxList listStory = [].obs;
  RxInt currentIndex = 0.obs;
  RxString idStory = "".obs;

  RxDouble progress = 0.0.obs;
  RxBool isPaused = false.obs;
  Timer? progressTimer;
  Timer? storyTimer;

  RxBool showActionIcon = false.obs;
  Rx<IconData> actionIcon = Icons.pause.obs;

  Timer? iconTimer;

  void nextStory() {
    if (currentIndex.value < listStory.length - 1) {
      currentIndex.value++;
      startStoryTimer();
    } else {
      Get.back();
    }
  }

  void previousStory() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      startStoryTimer();
    }
  }

  void startStoryTimer() {
    storyTimer?.cancel();
    progressTimer?.cancel();

    isPaused.value = false;
    progress.value = 0;

    progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      progress.value += 0.01;

      if (progress.value >= 1) {
        progress.value = 1;
        timer.cancel();
      }
    });

    storyTimer = Timer(const Duration(seconds: 5), () {
      nextStory();
    });
  }

  void togglePause() {
    if (isPaused.value) {
      resumeStory();
    } else {
      pauseStory();
    }
  }

  void pauseStory() {
    isPaused.value = true;

    showCenterIcon(Icons.pause);

    storyTimer?.cancel();
    progressTimer?.cancel();
  }

  void resumeStory() {
    isPaused.value = false;

    showCenterIcon(Icons.play_arrow);

    final remainingProgress = 1 - progress.value;

    progressTimer?.cancel();
    storyTimer?.cancel();

    progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (isPaused.value) {
        timer.cancel();
        return;
      }

      progress.value += 0.01;

      if (progress.value >= 1) {
        progress.value = 1;
        timer.cancel();
      }
    });

    storyTimer = Timer(
      Duration(milliseconds: (5000 * remainingProgress).toInt()),
      () {
        nextStory();
      },
    );
  }

  void showCenterIcon(IconData icon) {
    actionIcon.value = icon;
    showActionIcon.value = true;

    iconTimer?.cancel();

    iconTimer = Timer(const Duration(milliseconds: 600), () {
      showActionIcon.value = false;
    });
  }

  void getDetailList(var id) async {
    try {
      final res = await Api.getDetailStory(id);
      final resJson = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        listStory.assignAll(resJson['data']);
        startStoryTimer();
      } else {
        print("Gagal mengambil data : ${res.body}");
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    }
  }

  @override
  void onInit() {
    final args = Get.arguments;

    if (args['idStory'] != null) {
      idStory.value = args['idStory'] ?? '';
      getDetailList(idStory.value);
    }
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    progressTimer?.cancel();
    storyTimer?.cancel();
    super.onClose();
  }
}
