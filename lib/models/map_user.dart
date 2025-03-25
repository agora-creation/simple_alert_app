class MapUserModel {
  String _id = '';
  String _name = '';
  String _email = '';

  String get id => _id;
  String get name => _name;
  String get email => _email;

  MapUserModel.fromMap(Map data) {
    _id = data['id'] ?? '';
    _name = data['name'] ?? '';
    _email = data['email'] ?? '';
  }

  Map toMap() => {
        'id': _id,
        'name': _name,
        'email': _email,
      };
}
