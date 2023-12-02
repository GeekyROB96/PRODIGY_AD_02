class Todo {
  final String id;
  String name;
  bool completed;

  Todo({
    required this.id,
    required this.name,
    required this.completed,
  });

  Todo.fromMap(Map<String, dynamic> map)
      : this.id = map['id'],
        this.name = map['name'],
        this.completed = map['completed'];

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'completed': this.completed,
    };
  }
}
