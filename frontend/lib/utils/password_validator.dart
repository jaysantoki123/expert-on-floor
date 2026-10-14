/// Shared password strength validator.
///
/// Policy (OWASP ASVS aligned):
///   - Minimum 8 characters
///   - At least 1 uppercase letter (A–Z)
///   - At least 1 lowercase letter (a–z)
///   - At least 1 digit (0–9)
///   - At least 1 special character
class PasswordValidator {
  PasswordValidator._();

  static const int _minLength = 8;

  /// Returns an error message if [password] does not meet the policy,
  /// or `null` if it is valid.
  static String? validate(String password) {
    if (password.length < _minLength) {
      return 'Password must be at least $_minLength characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must include at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must include at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must include at least one number';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{};:''",.<>?/\\|`~]'))) {
      return 'Password must include at least one special character';
    }
    return null;
  }
}
