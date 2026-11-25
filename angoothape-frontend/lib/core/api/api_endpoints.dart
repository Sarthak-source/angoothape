class ApiEndpoints {
  static const String health = '/health';

  static const String catalog = '/catalog';

  static const String authBase = '/auth';
  static const String login = '$authBase/login';
  static const String totp = '$authBase/totp';
  static const String otp = '$authBase/otp';
  static const String resendOtp = '$authBase/resend';
  static const String logout = '$authBase/logout';
  static const String forgot = '$authBase/forgot';
  static const String forgotConfirm = '$authBase/forgot/confirm';

  static const String joinBase = '/join';
  static const String join = joinBase;
  static const String joinEkyc = '$joinBase/ekyc';
  static String joinApprove(String applicationId) =>
      '$joinBase/$applicationId/approve';

  static const String apiBase = '/api';
  static const String me = '$apiBase/me';
  static const String mePreferences = '$apiBase/me/preferences';
  static const String mePassword = '$apiBase/me/password';
  static const String demoReset = '$apiBase/demo/reset';

  static const String aeps = '$apiBase/aeps';

  static const String transactions = '$apiBase/transactions';
  static String transaction(String ref) => '$transactions/$ref';
  static String transactionCheck(String ref) => '$transactions/$ref/check';

  static const String settlements = '$apiBase/settlements';
  static const String accounts = '$apiBase/accounts';
  static const String walletTopup = '$apiBase/wallet/topup';

  static const String tickets = '$apiBase/tickets';

  static const String device = '$apiBase/device';
  static const String deviceTest = '$apiBase/device/test';
  static const String deviceRequests = '$apiBase/device/requests';

  static String receiptAction(String ref) => '$apiBase/receipts/$ref/actions';
  static const String exports = '$apiBase/exports';
}
