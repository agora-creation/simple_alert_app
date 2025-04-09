class MapUserModel {
  String _id = '';
  String _name = '';
  String answer = '';

  String get id => _id;
  String get name => _name;

  MapUserModel.fromMap(Map data) {
    _id = data['id'] ?? '';
    _name = data['name'] ?? '';
    answer = data['answer'] ?? '';
  }

  Map toMap() => {
        'id': _id,
        'name': _name,
        'answer': answer,
      };
}
