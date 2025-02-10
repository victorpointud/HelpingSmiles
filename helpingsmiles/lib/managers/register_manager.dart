/// Clase para manejar la lógica del registro.
class RegisterManager {

  /// Valida que la contraseña y la confirmación sean iguales.
  static bool validateRegistration(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
