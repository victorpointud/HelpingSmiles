class RegisterManager {
  /// Validates if password and confirmation match
  static bool validatePasswords(String password, String confirmPassword) => password == confirmPassword;
}
