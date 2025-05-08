class SendUserModel {
  String _id = '';
  String _name = '';
  String answer = '';
  bool read = false;

  String get id => _id;
  String get name => _name;

  SendUserModel.fromMap(Map data) {
    _id = data['id'] ?? '';
    _name = data['name'] ?? '';
    answer = data['answer'] ?? '';
    read = data['read'] ?? false;
  }

  Map toMap() => {
        'id': _id,
        'name': _name,
        'answer': answer,
        'read': read,
      };
}
