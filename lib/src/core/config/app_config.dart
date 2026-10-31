class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://umbrella.delimitationproduction.com/api',
  );

  static const String appName = 'Umbrella';
  static const String appTagline = 'Watch. Scroll. Vote. Reward. Earn.';
  static const bool enableDevSubscription = bool.fromEnvironment(
    'ENABLE_DEV_SUBSCRIPTION',
    defaultValue: false,
  );
}
