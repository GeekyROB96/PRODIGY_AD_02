import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

//import 'package:page_transition/page_transition.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AnimatedSplashScreen(
        duration: 3000,
        splashTransition: SplashTransition.sizeTransition,
        backgroundColor: Colors.blue,
        nextScreen: ToDoApp(),
        splashIconSize: 300,
        splash: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check,
              size: 100,
              color: Colors.white,
            ),
            Text(
              'ToDo App',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TodoList(title: 'Todo Manager'),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({super.key, required this.title});

  final String title;

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late SharedPreferences sharedPreferences;
  final List<Todo> _todos = <Todo>[];

  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  void initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
  }

  void _addTodoItem(String name) {
    setState(() {
      String randomId = generateRandomId(10);
      _todos.add(Todo(id: randomId, name: name, completed: false));
    });
    saveData();
    _textFieldController.clear();
  }

  void _handleTodoChange(Todo todo) {
    setState(() {
      todo.completed = !todo.completed;
    });
    saveData();
  }

  void _deleteTodo(Todo todo) {
    setState(() {
      _todos.removeWhere((element) => element == todo);
    });
    saveData();
  }

  void editTodo(Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _editController = TextEditingController()
          ..text = todo.name;

        return AlertDialog(
          title: const Text('Edit ToDo'),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(hintText: 'Edit your Todo'),
            autofocus: true,
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  todo.name = _editController.text;
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    saveData();
  }

  void _displayDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add A ToDo'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Type your Todo'),
            autofocus: true,
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _addTodoItem(_textFieldController.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _todos.isEmpty
          ? Center(
              child: Text(
                'No Todo Tasks',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: _todos.map((Todo todo) {
                return TodoItem(
                  todo: todo,
                  onTodoChanged: _handleTodoChange,
                  removeTodo: _deleteTodo,
                  editTodo: editTodo,
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _displayDialog,
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  String generateRandomId(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      List.generate(length, (index) {
        return chars.codeUnitAt(random.nextInt(chars.length));
      }),
    );
  }

  void saveData() {
    List<String> spList =
        _todos.map((item) => jsonEncode(item.toMap())).toList();
    sharedPreferences.setStringList('todos', spList);
  }

  void loadData() {
    List<String>? spList = sharedPreferences.getStringList('todos');
    if (spList != null) {
      _todos.clear();
      spList.forEach((item) {
        _todos.add(Todo.fromMap(jsonDecode(item)));
      });
      setState(() {});
    }
  }
}

class TodoItem extends StatelessWidget {
  TodoItem({
    Key? key,
    required this.todo,
    required this.onTodoChanged,
    required this.removeTodo,
    required this.editTodo,
  }) : super(key: key);

  final Todo todo;
  final void Function(Todo todo) onTodoChanged;
  final void Function(Todo todo) removeTodo;
  final void Function(Todo todo) editTodo;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return const TextStyle(
      color: Colors.black38,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTodoChanged(todo);
      },
      leading: Checkbox(
        checkColor: Colors.greenAccent,
        activeColor: Colors.red,
        value: todo.completed,
        onChanged: (value) {
          onTodoChanged(todo);
        },
      ),
      title: Row(children: <Widget>[
        Expanded(
          child: Text(
            todo.name,
            style: _getTextStyle(todo.completed),
          ),
        ),
        IconButton(
          iconSize: 28,
          icon: const Icon(
            Icons.edit,
            color: Colors.red,
          ),
          onPressed: () {
            editTodo(todo);
          },
        ),
        IconButton(
          iconSize: 29,
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          alignment: Alignment.centerRight,
          onPressed: () {
            removeTodo(todo);
          },
        ),
      ]),
    );
  }
}
