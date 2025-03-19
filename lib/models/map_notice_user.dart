class MapNoticeUserModel {
  String _id = '';
  String _senderNumber = '';
  String _senderName = '';

  String get id => _id;
  String get senderNumber => _senderNumber;
  String get senderName => _senderName;

  MapNoticeUserModel.fromMap(Map data) {
    _id = data['id'] ?? '';
    _senderNumber = data['senderNumber'] ?? '';
    _senderName = data['senderName'] ?? '';
  }

  Map toMap() => {
        'id': _id,
        'senderNumber': _senderNumber,
        'senderName': _senderName,
      };
}
