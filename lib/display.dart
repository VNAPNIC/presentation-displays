Display displayFromJson(Map<String, dynamic> json) => Display(
    displayId: json['displayId'],
    flag: json['flags'],
    name: json['name'],
    rotation: json['rotation']);

/// Provides information about of a logical display.
class Display {
  int displayId;
  int flag;
  int rotation;
  String name;

  Display({this.displayId, this.flag, this.name, this.rotation});
}
