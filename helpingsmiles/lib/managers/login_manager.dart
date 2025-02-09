/// Clase para manejar la lógica del login.
class LoginManager {
  /// Valida el usuario con credenciales estáticas.
  static bool validateUser(String username, String password) {
    return username == 'admin' && password == '1234';
  }
}
