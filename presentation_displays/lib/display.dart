class Display{

  int displayId;
  int flag;
  int rotation;
  String name;

  Display({this.displayId, this.flag, this.name, this.rotation});

  Display.fromJson(Map<String, dynamic> json) {
    displayId = json['displayId'];
    flag = json['flags'];
    name = json['name'];
    rotation = json['rotation'];
  }

}
