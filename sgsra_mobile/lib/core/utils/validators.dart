/// Validaciones lógicas para el frontend previas al envío al Backend
class AppValidators {
  static String? validarDni(String? value) {
    if (value == null || value.trim().isEmpty) return 'El DNI es obligatorio.';
    final clean = value.trim();
    if (clean.length != 8 || !RegExp(r'^[0-9]{8}$').hasMatch(clean)) {
      return 'El DNI debe tener exactamente 8 dígitos numéricos.';
    }
    return null;
  }

  static String? validarTelefono(String? value) {
    if (value == null || value.trim().isEmpty) return 'El teléfono es obligatorio.';
    final clean = value.trim();
    if (!clean.startsWith('9')) {
      return 'El teléfono debe iniciar con el dígito 9.';
    }
    if (clean.length != 9 || !RegExp(r'^9[0-9]{8}$').hasMatch(clean)) {
      return 'El teléfono debe contener exactamente 9 dígitos numéricos.';
    }
    return null;
  }

  static String? validarNombre(String? value) {
    if (value == null || value.trim().isEmpty) return 'El nombre es obligatorio.';
    final clean = value.trim();
    if (clean.length < 3) return 'El nombre debe tener al menos 3 caracteres.';
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(clean)) {
      return 'El nombre solo debe contener letras y espacios (sin números).';
    }
    return null;
  }

  static String? validarStock(String? value, {String campo = 'Stock'}) {
    if (value == null || value.trim().isEmpty) return '$campo es obligatorio.';
    final num = int.tryParse(value.trim());
    if (num == null) return '$campo debe ser un número entero válido.';
    if (num < 0) return '$campo no puede ser un valor negativo.';
    return null;
  }

  static String? validarCorreo(String? value) {
    if (value == null || value.trim().isEmpty) return 'El correo es obligatorio.';
    final clean = value.trim().toLowerCase();
    if (!clean.endsWith('@masterdrilling.com')) {
      return 'Debe usar su correo corporativo (@masterdrilling.com).';
    }
    return null;
  }
}
