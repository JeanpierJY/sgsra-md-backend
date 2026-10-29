/// Validaciones lógicas para el frontend previas al envío al Backend
class AppValidators {
  static String? validarDni(String? value) {
    if (value == null || value.isEmpty) return 'El DNI es obligatorio.';
    if (value.length < 8) return 'El DNI debe tener al menos 8 dígitos.';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'El DNI solo debe contener números.';
    return null;
  }

  static String? validarTelefono(String? value) {
    if (value == null || value.isEmpty) return 'El teléfono es obligatorio.';
    if (value.length != 9) return 'El teléfono debe tener exactamente 9 dígitos.';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'El teléfono solo debe contener números.';
    return null;
  }

  static String? validarCorreo(String? value) {
    if (value == null || value.isEmpty) return 'El correo es obligatorio.';
    if (!value.endsWith('@masterdrilling.com')) {
      return 'Debe usar su correo corporativo (@masterdrilling.com).';
    }
    return null;
  }
}