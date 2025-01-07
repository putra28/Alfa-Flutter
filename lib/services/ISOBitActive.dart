class ISOBitActive {
  String type;
  int length;
  String format;
  String status;
  String data;
  bool isOpen;

  // Default constructor with initializer list
  ISOBitActive(): 
    type = "",
    length = 0,
    format = "",
    status = "",
    data = "",
    isOpen = false;

  // Named constructor with parameters
  ISOBitActive.withParams(
    this.type,
    this.length,
    this.format,
    this.status,
    this.data,
    this.isOpen,
  );

  // Getters and setters
  bool getIsOpen() => isOpen;
  void setIsOpen(bool value) => isOpen = value;

  String getFormat() => format;
  
  String getData() => data;
  void setData(String value) => data = value;

  int getLength() => length;
  void setLength(int value) => length = value;

  // Static method to reset data types
  static List<ISOBitActive> ISOResetBit(int lengthbit) {
    List<ISOBitActive>? outresponse;
    try {
      var datatipes = List<ISOBitActive>.generate(
        lengthbit,
        (index) => ISOBitActive(),
      );

      datatipes[0]
        ..type = "h"
        ..length = 16
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[1]
        ..type = "h"
        ..length = 16
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[2]
        ..type = "n"
        ..length = 99
        ..format = "LLVAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[3]
        ..type = "n"
        ..length = 6
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[4]
        ..type = "n"
        ..length = 12
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[7]
        ..type = "n"
        ..length = 10
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[11]
        ..type = "n"
        ..length = 6
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[12]
        ..type = "HHmmss"
        ..length = 6
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[13]
        ..type = "MMdd"
        ..length = 4
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[14]
        ..type = "MMdd"
        ..length = 4
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[15]
        ..type = "MMdd"
        ..length = 4
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[18]
        ..type = "n"
        ..length = 4
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[22]
        ..type = "n"
        ..length = 3
        ..format = "VAR"
        ..status = "O"
        ..data = ""
        ..isOpen = false;

      datatipes[25]
        ..type = "n"
        ..length = 2
        ..format = "VAR"
        ..status = "O"
        ..data = ""
        ..isOpen = false;

      datatipes[26]
        ..type = "n"
        ..length = 2
        ..format = "VAR"
        ..status = "O"
        ..data = ""
        ..isOpen = false;

      datatipes[27]
        ..type = "n"
        ..length = 1
        ..format = "VAR"
        ..status = "O"
        ..data = ""
        ..isOpen = false;

      datatipes[32]
        ..type = "an"
        ..length = 99
        ..format = "LLVAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[33]
        ..type = "an"
        ..length = 99
        ..format = "LLVAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[35]
        ..type = "an"
        ..length = 99
        ..format = "LLVAR"
        ..status = "O"
        ..data = ""
        ..isOpen = false;

      datatipes[37]
        ..type = "an"
        ..length = 12
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[38]
        ..type = "an"
        ..length = 6
        ..format = "VAR"
        ..status = "O"
        ..data = ""
        ..isOpen = false;

      datatipes[39]
        ..type = "n"
        ..length = 2
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[41]
        ..type = "ans"
        ..length = 8
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[42]
        ..type = "ans"
        ..length = 15
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[43]
        ..type = "ans"
        ..length = 40
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[48]
        ..type = "ans"
        ..length = 999
        ..format = "LLLVAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[49]
        ..type = "n"
        ..length = 3
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[52]
        ..type = "an"
        ..length = 16
        ..format = "VAR"
        ..status = "O"
        ..data = ""
        ..isOpen = false;

      datatipes[54]
        ..type = "an"
        ..length = 999
        ..format = "LLLVAR"
        ..status = "O"
        ..data = ""
        ..isOpen = false;

      datatipes[60]
        ..type = "ans"
        ..length = 999
        ..format = "LLLVAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[61]
        ..type = "ans"
        ..length = 999
        ..format = "LLLVAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[62]
        ..type = "ans"
        ..length = 999
        ..format = "LLLVAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[63]
        ..type = "ans"
        ..length = 999
        ..format = "LLLVAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[70]
        ..type = "n"
        ..length = 3
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[90]
        ..type = "n"
        ..length = 42
        ..format = "VAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      datatipes[103]
        ..type = "n"
        ..length = 99
        ..format = "LLVAR"
        ..status = "M"
        ..data = ""
        ..isOpen = false;

      outresponse = datatipes;
    } catch (e) {
      rethrow;
    }
    return outresponse!;
  }
}