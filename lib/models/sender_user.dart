class SenderUserModel {
  String _id = '';
  String _number = '';
  String _name = '';

  String get id => _id;
  String get number => _number;
  String get name => _name;

  SenderUserModel.fromMap(Map data) {
    _id = data['id'] ?? '';
    _number = data['number'] ?? '';
    _name = data['name'] ?? '';
  }

  Map toMap() => {
        'id': _id,
        'number': _number,
        'name': _name,
      };
}
