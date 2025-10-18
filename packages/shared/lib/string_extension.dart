
import 'dart:convert';

extension StringExtension on String {
  bool isBlank() {
    return trim().isEmpty;
  }

  List<int> base16decode() {
    if (length % 2 != 0) {
      throw FormatException("only even number");
    }

    List<int> result = [];
    for (int i = 0; i < length; i += 2) {
      String byteStr = substring(i, i + 2);
      int byteValue = int.parse(byteStr, radix: 16);
      result.add(byteValue);
    }
    return result;
  }
}


