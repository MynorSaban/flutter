class CuiValidator {
  static bool validateDPI(String? dpi) {
    // Validación inicial de nulos o vacíos
    if (dpi == null || dpi.trim().isEmpty) {
      return false;
    }

    // El DPI debe tener exactamente 13 caracteres
    if (dpi.length != 13) {
      return false;
    }

    // Expresión regular para verificar que sean solo dígitos
    final regex = RegExp(r'^[0-9]{13}$');
    if (!regex.hasMatch(dpi)) {
      return false;
    }

    final dpiNum = dpi.substring(0, 8);
    final validatorNumber = dpi[8];
    
    // Convertir de forma segura los códigos de departamento y municipio
    final stateCode = int.tryParse(dpi.substring(9, 11));
    final cityCode = int.tryParse(dpi.substring(11, 13));

    if (stateCode == null || cityCode == null) {
      return false;
    }

    // Listado de municipios por departamento de Guatemala
    final List<int> stateCityCounts = [
      17, // 01 - Guatemala
      8,  // 02 - El Progreso
      16, // 03 - Sacatepéquez
      16, // 04 - Chimaltenango
      13, // 05 - Escuintla
      14, // 06 - Santa Rosa
      19, // 07 - Sololá
      8,  // 08 - Totonicapán
      24, // 09 - Quetzaltenango
      21, // 10 - Suchitepéquez
      9,  // 11 - Retalhuleu
      30, // 12 - San Marcos
      32, // 13 - Huehuetenango
      21, // 14 - Quiché
      8,  // 15 - Baja Verapaz
      17, // 16 - Alta Verapaz
      14, // 17 - Petén
      5,  // 18 - Izabal
      11, // 19 - Zacapa
      11, // 20 - Chiquimula
      7,  // 21 - Jalapa
      17, // 22 - Jutiapa
    ];

    // Validar rangos de departamentos
    if (stateCode < 1 || stateCode > stateCityCounts.length) {
      return false;
    }

    // Validar rango de municipios para ese departamento específico
    if (cityCode < 1 || cityCode > stateCityCounts[stateCode - 1]) {
      return false;
    }

    // Algoritmo de módulo 11
    final valNumberInt = int.tryParse(validatorNumber);
    if (valNumberInt == null) return false;

    return _calculateMod(dpiNum) % 11 == valNumberInt;
  }

  static int _calculateMod(String codigo) {
    int total = 0;
    for (int i = 0; i < codigo.length; i++) {
      final digito = int.tryParse(codigo[i]);
      if (digito != null) {
        total += digito * (i + 2);
      }
    }
    return total;
  }
}
