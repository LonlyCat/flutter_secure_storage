part of flutter_secure_storage;

/// KeyChain accessibility attributes as defined here:
/// https://developer.apple.com/documentation/security/ksecattraccessible?language=objc
enum KeychainAccessibility {
  /// The data in the keychain can only be accessed when the device is unlocked.
  /// Only available if a passcode is set on the device.
  /// Items with this attribute do not migrate to a new device.
  passcode,

  /// The data in the keychain item can be accessed only while the device is unlocked by the user.
  unlocked,

  /// The data in the keychain item can be accessed only while the device is unlocked by the user.
  /// Items with this attribute do not migrate to a new device.
  unlocked_this_device,

  /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
  first_unlock,

  /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
  /// Items with this attribute do not migrate to a new device.
  first_unlock_this_device,
}

abstract class AppleOptions extends Options {
  const AppleOptions({
    String? groupId,
    String? accountName = AppleOptions.defaultAccountName,
    String? localizedReason,
    KeychainAccessibility accessibility = KeychainAccessibility.unlocked,
    bool skipAuthenticationItem = false,
    bool useAccessControl = false,
    bool synchronizable = false,
  })  : _groupId = groupId,
        _accessibility = accessibility,
        _accountName = accountName,
        _localizedReason = localizedReason,
        _useAccessControl = useAccessControl,
        _skipAuthenticationItem = skipAuthenticationItem,
        _synchronizable = synchronizable;

  static const defaultAccountName = 'flutter_secure_storage_service';

  final String? _groupId;
  final String? _accountName;
  final String? _localizedReason;
  final KeychainAccessibility _accessibility;
  final bool _synchronizable;
  final bool _useAccessControl;
  // A value that indicates items requiring user authentication should be skipped.
  final bool _skipAuthenticationItem;

  @override
  Map<String, String> toMap() => <String, String>{
        'accessibility': describeEnum(_accessibility),
        if (_groupId != null) 'groupId': _groupId!,
        if (_accountName != null) 'accountName': _accountName!,
        if (_localizedReason != null) 'localizedReason': _localizedReason!,
        'synchronizable': '$_synchronizable',
        'useAccessControl': '$_useAccessControl',
        'skipAuthenticationItem': '$_skipAuthenticationItem',
      };
}
