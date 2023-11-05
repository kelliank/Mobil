import 'package:flutter/material.dart';
import 'package:todo_app_sqlite_freezed/models/DatabaseHelper.dart';
import 'package:todo_app_sqlite_freezed/models/todo_model.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FutureBuilderExample(),
    );
  }
}

class FutureBuilderExample extends StatefulWidget {
  const FutureBuilderExample({Key? key}) : super(key: key);
  final String title = "ToDo Page";


  @override
  State<FutureBuilderExample> createState() => _FutureBuilderExampleState();
}

class _FutureBuilderExampleState extends State<FutureBuilderExample> {
  
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Todo>>(
  future: DatabaseHelper.instance.getAllTodos(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Erreur : ${snapshot.error}');
    }

    List<Todo> todos = snapshot.data ?? [];
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              Todo todo = todos[index];
              return CheckboxListTile(
              title: Text(todo.task),
              value: todo.isCompleted,
              onChanged: (bool? value) {
                final updatedTodo = todo.copyWith(isCompleted: value ?? false);
                setState(() {
                  DatabaseHelper.instance.update(updatedTodo);
                });
              },
            );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
                       ElevatedButton(
              onPressed: () {
                _deleteSelectedTodos(todos);
              },
              child: Text('Supprimer'),
            ),
            ElevatedButton(
          onPressed: () {
            _showAddTaskDialog(context);
          },
          child: Text('Ajouter'),
        ),
          ],
        ),
      ],
    );
  },
),
    );
  }

void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une tâche'),
          content: TextField(
            controller: _taskController,
            decoration: InputDecoration(labelText: 'Nom de la tâche'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () {
                String task = _taskController.text;
                if (task.isNotEmpty) {
                  DatabaseHelper.instance.insert(Todo(task: task, isCompleted: false));
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedTodos(List<Todo> todos) {
  final completedTodos = todos.where((todo) => todo.isCompleted).toList();
  for (var todo in completedTodos) {
    DatabaseHelper.instance.delete(todo.id!);
  }
  
  setState(() {
    todos.removeWhere((todo) => todo.isCompleted);
  });
}






}