import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task title cannot be empty.')),
      );
      return;
    }

    await _taskService.addTask(title);
    _taskController.clear();
  }

  Future<void> _showDeleteDialog(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _taskService.deleteTask(task.id);
    }
  }

  Future<void> _showAddSubtaskDialog(Task task) async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter subtask name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                await _taskService.addSubtask(task, text);
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Task Manager'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a new task',
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search tasks',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskService.streamTasks(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong while loading tasks.'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data ?? [];
                final filteredTasks = tasks.where((task) {
                  return task.title.toLowerCase().contains(_searchText);
                }).toList();

                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('No tasks yet — add one above!'),
                  );
                }

                if (filteredTasks.isEmpty) {
                  return const Center(
                    child: Text('No matching tasks found.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ExpansionTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) async {
                            await _taskService.toggleTaskCompletion(
                              task,
                              value ?? false,
                            );
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          '${task.subtasks.length} subtasks',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteDialog(task),
                        ),
                        children: [
                          if (task.subtasks.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('No subtasks yet.'),
                              ),
                            )
                          else
                            ...List.generate(task.subtasks.length, (subIndex) {
                              final subtask = task.subtasks[subIndex];
                              final subtaskTitle = subtask['title'] ?? '';
                              final subtaskDone =
                                  subtask['isCompleted'] ?? false;

                              return ListTile(
                                leading: Checkbox(
                                  value: subtaskDone,
                                  onChanged: (value) async {
                                    await _taskService.toggleSubtask(
                                      task,
                                      subIndex,
                                      value ?? false,
                                    );
                                  },
                                ),
                                title: Text(
                                  subtaskTitle,
                                  style: TextStyle(
                                    decoration: subtaskDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    await _taskService.deleteSubtask(
                                      task,
                                      subIndex,
                                    );
                                  },
                                ),
                              );
                            }),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: () => _showAddSubtaskDialog(task),
                                icon: const Icon(Icons.add),
                                label: const Text('Add subtask'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
