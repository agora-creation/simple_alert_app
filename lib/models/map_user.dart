class MapUserModel {
  String _id = '';
  String _name = '';
  String _tel = '';

  String get id => _id;
  String get name => _name;
  String get tel => _tel;

  MapUserModel.fromMap(Map data) {
    _id = data['id'] ?? '';
    _name = data['name'] ?? '';
    _tel = data['tel'] ?? '';
  }

  Map toMap() => {
        'id': _id,
        'name': _name,
        'tel': _tel,
      };
}
