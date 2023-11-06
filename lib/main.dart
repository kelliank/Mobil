import 'package:flutter/material.dart';
import 'package:todo_app_sqlite_freezed/models/DatabaseHelper.dart';
import 'package:todo_app_sqlite_freezed/models/todo_model.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  //calling the FutureBuilder Page
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FutureBuilderExample(),
    );
  }
}

class FutureBuilderExample extends StatefulWidget {
  const FutureBuilderExample({Key? key}) : super(key: key);
  final String title = "TP 2";
  @override
  State<FutureBuilderExample> createState() => _FutureBuilderExampleState();
}

//content of the FutureBuilder Page
class _FutureBuilderExampleState extends State<FutureBuilderExample> {
  
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
        widget.title,
        style: TextStyle(color: Colors.black), 
      ),
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
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.blue,
      ),
      onDismissed: (direction) {
        _showEditTaskDialog(context, todo);
      },
      child: CheckboxListTile(
        title: Text(todo.task), 
        value: todo.isCompleted,
        onChanged: (bool? value) {
          final updatedTodo = todo.copyWith(isCompleted: value ?? false);
          setState(() {
            DatabaseHelper.instance.update(updatedTodo);
          });
        },
      ),
    );
  },
)

        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
                       ElevatedButton(
              onPressed: () {
                _deleteSelectedTodos(todos);
              },
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
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

//adding a add-task pop up
void _showAddTaskDialog(BuildContext context) {
    _taskController.clear(); //clear the past writting
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

  //method for delete the selected tasks
  void _deleteSelectedTodos(List<Todo> todos) {
  final completedTodos = todos.where((todo) => todo.isCompleted).toList();
  for (var todo in completedTodos) {
    DatabaseHelper.instance.delete(todo.id!);
  }
  //updating the state
  setState(() {
    todos.removeWhere((todo) => todo.isCompleted);
  });
}

void _showEditTaskDialog(BuildContext context, Todo todo) {
  final TextEditingController _editTaskController = TextEditingController();
  _editTaskController.text = todo.task;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Modifier la tâche'),
        content: TextField(
          controller: _editTaskController,
          decoration: InputDecoration(labelText: 'Nouveau nom de la tâche'),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Enregistrer'),
            onPressed: () {
              String newTask = _editTaskController.text;
              if (newTask.isNotEmpty) {
                final updatedTodo = todo.copyWith(task: newTask);
                DatabaseHelper.instance.update(updatedTodo);
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
}