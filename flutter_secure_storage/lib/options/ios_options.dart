part of flutter_secure_storage;

/// Specific options for iOS platform.
class IOSOptions extends AppleOptions {
  const IOSOptions({
    String? groupId,
    String? accountName = AppleOptions.defaultAccountName,
    KeychainAccessibility accessibility = KeychainAccessibility.unlocked,
    bool useAccessControl = false,
    bool synchronizable = false,
  }) : super(
          groupId: groupId,
          accountName: accountName,
          accessibility: accessibility,
          useAccessControl: useAccessControl,
          synchronizable: synchronizable,
        );

  static const IOSOptions defaultOptions = IOSOptions();

  IOSOptions copyWith({
    String? groupId,
    String? accountName,
    KeychainAccessibility? accessibility,
    bool? useAccessControl,
    bool? synchronizable,
  }) =>
      IOSOptions(
        groupId: groupId ?? _groupId,
        accountName: accountName ?? _accountName,
        accessibility: accessibility ?? _accessibility,
        synchronizable: synchronizable ?? _synchronizable,
        useAccessControl: useAccessControl ?? _useAccessControl,
      );
}
