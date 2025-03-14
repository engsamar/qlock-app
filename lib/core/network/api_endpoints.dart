abstract class ApiEndpoints {
  static const String validateMobile = 'validate-mobile';
  static const String verifyMobile = 'verify-mobile';
  static const String updateProfile = 'profile/update';
  static const String profile = 'profile';
  static const String conversations = 'conversations';
  static const String messages = 'messages';
  static String conversationById({required int id}) => 'conversations/$id';
  static String messagesById({required int id}) => 'messages/$id';
  static String markMessageAsReadById({required int id}) => 'messages/$id/read';
}