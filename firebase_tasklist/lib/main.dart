import 'package:flutter/material.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const TaskListScreen(),
    );
  }
}

class Task {
  String name;
  bool isCompleted;
  Map<String, Map<String, List<String>>> subTasks;

  Task({
    required this.name,
    this.isCompleted = false,
    this.subTasks = const {},
  });
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _initializeDefaultTasks();
  }

  void _initializeDefaultTasks() {
    _tasks.addAll([
      Task(
        name: 'Study Flutter',
        subTasks: {
          'Monday': {
            '9 am - 10 am': ['Widgets Overview', 'StatefulWidget Practice'],
          },
        },
      ),
      Task(
        name: 'Gym Session',
        subTasks: {
          'Tuesday': {
            '6 pm - 7 pm': ['Cardio', 'Stretching'],
          },
        },
      ),
      Task(
        name: 'Grocery Shopping',
        subTasks: {
          'Wednesday': {
            '5 pm - 6 pm': ['Buy Fruits', 'Buy Milk'],
          },
        },
      ),
      Task(
        name: 'Project Meeting',
        subTasks: {
          'Thursday': {
            '2 pm - 3 pm': ['Team Sync', 'Update Timeline'],
          },
        },
      ),
      Task(
        name: 'Watch Tutorial',
        subTasks: {
          'Friday': {
            '7 pm - 8 pm': ['YouTube Playlist'],
          },
        },
      ),
    ]);
  }

  void _addTask() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _tasks.add(Task(name: _controller.text, subTasks: {}));
      _controller.clear();
    });
  }

  void _toggleTask(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
  }

  void _addSubTask(Task task) {
    final dayController = TextEditingController();
    final timeController = TextEditingController();
    final detailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subtask'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dayController,
                decoration: const InputDecoration(labelText: 'Day'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time Range'),
              ),
              TextField(
                controller: detailController,
                decoration: const InputDecoration(
                  labelText: 'Subtask Details (comma separated)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final day = dayController.text.trim();
                final time = timeController.text.trim();
                final details =
                    detailController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList();

                if (day.isEmpty || time.isEmpty || details.isEmpty) return;

                setState(() {
                  task.subTasks.putIfAbsent(day, () => {});
                  task.subTasks[day]!.putIfAbsent(time, () => []);
                  task.subTasks[day]![time]!.addAll(details);
                });

                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubTasks(Task task) {
    return Column(
      children:
          task.subTasks.entries.map((dayEntry) {
            return ExpansionTile(
              title: Text(dayEntry.key),
              children:
                  dayEntry.value.entries.map((timeEntry) {
                    return ListTile(
                      title: Text(timeEntry.key),
                      subtitle: Text(timeEntry.value.join(', ')),
                    );
                  }).toList(),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () {})],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter task name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addTask, child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child:
                _tasks.isEmpty
                    ? const Center(child: Text('No tasks added yet.'))
                    : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (_) => _toggleTask(task),
                                ),
                                Expanded(
                                  child: Text(
                                    task.name,
                                    style: TextStyle(
                                      decoration:
                                          task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => _addSubTask(task),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteTask(task),
                                ),
                              ],
                            ),
                            children: [_buildSubTasks(task)],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
