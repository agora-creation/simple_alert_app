class MapUserModel {
  String _id = '';
  String _name = '';
  String _tel = '';
  String answer = '';

  String get id => _id;
  String get name => _name;
  String get tel => _tel;

  MapUserModel.fromMap(Map data) {
    _id = data['id'] ?? '';
    _name = data['name'] ?? '';
    _tel = data['tel'] ?? '';
    answer = data['answer'] ?? '';
  }

  Map toMap() => {
        'id': _id,
        'name': _name,
        'tel': _tel,
        'answer': answer,
      };
}
