class ChatUser {
  ChatUser({
    required this.id,
    required this.name,
    required this.email
  });

  factory ChatUser.fromMap(Map<String, dynamic> data) {
    return ChatUser(id: data['id'], name: data['name'], email: data['email']);
  }

  final String id;
  final String name;
  final String email;
}