class ZegoConfig {
  static int appID = 1693417836; // dari dashboard
  static String appSign = "6095bc5893e5c496334122d32c558590a9cd663057bcc54f52c690c9cf040801";

  static String userID = "";
  static String userName = "";

  static void init({
    required String id,
    required String name,
  }) {
    userID = id;
    userName = name;
  }
}