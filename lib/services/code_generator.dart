import 'dart:math';

class CodeGenerator {
  CodeGenerator._();

  static CodeGenerator? _instance;

  static CodeGenerator? get instance {
    if (_instance == null) {
      _instance = CodeGenerator._();
    }
    return _instance;
  }

  Random random = Random();

  String generateCode(String prefix) {
    var id = random.nextInt(92143543) + 09451234356;
    return '$prefix-${id.toString().substring(0, 8)}';
  }
}
