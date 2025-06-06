import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Notifier to handle a local state, that is a list of things to do related
// to the user's garden.
class TodoListNotifier extends StateNotifier<List<String>> {
  static const _key = 'garden_todo_list';

  TodoListNotifier() : super([]) {
    _loadTodos();
  }

  // Load the todo list from shared preferences.
  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todos = prefs.getStringList(_key) ?? [];
    state = todos;
  }

  // Save the current todo list to shared preferences.
  Future<void> _saveTodos(List<String> todos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, todos);
  }

  // Add a new todo if it's not empty and not already in the list.
  Future<void> addTodo(String todo) async {
    if (todo.isEmpty || state.contains(todo)) return;
    final newList = [...state, todo];
    await _saveTodos(newList);
    state = newList;
  }

  // Remove a todo from the list.
  Future<void> removeTodo(String todo) async {
    final newList = state.where((t) => t != todo).toList();
    await _saveTodos(newList);
    state = newList;
  }

  // Clear all todos.
  Future<void> clearTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = [];
  }
} // end TodoListNotifier.


