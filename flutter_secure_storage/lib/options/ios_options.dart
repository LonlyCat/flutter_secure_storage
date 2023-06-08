part of flutter_secure_storage;

/// Specific options for iOS platform.
class IOSOptions extends AppleOptions {
  const IOSOptions({
    String? groupId,
    String? localizedReason,
    String? accountName = AppleOptions.defaultAccountName,
    KeychainAccessibility accessibility = KeychainAccessibility.unlocked,
    bool skipAuthenticationItem = false,
    bool useAccessControl = false,
    bool synchronizable = false,
  }) : super(
          groupId: groupId,
          accountName: accountName,
          accessibility: accessibility,
          localizedReason: localizedReason,
          skipAuthenticationItem: skipAuthenticationItem,
          useAccessControl: useAccessControl,
          synchronizable: synchronizable,
        );

  static const IOSOptions defaultOptions = IOSOptions();

  IOSOptions copyWith({
    String? groupId,
    String? accountName,
    String? localizedReason,
    KeychainAccessibility? accessibility,
    bool? skipAuthenticationItem,
    bool? useAccessControl,
    bool? synchronizable,
  }) =>
      IOSOptions(
        groupId: groupId ?? _groupId,
        accountName: accountName ?? _accountName,
        accessibility: accessibility ?? _accessibility,
        synchronizable: synchronizable ?? _synchronizable,
        localizedReason: localizedReason ?? _localizedReason,
        useAccessControl: useAccessControl ?? _useAccessControl,
        skipAuthenticationItem: skipAuthenticationItem ?? _skipAuthenticationItem,
      );
}
