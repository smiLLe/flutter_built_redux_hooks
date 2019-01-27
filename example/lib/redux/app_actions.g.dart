// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_actions.dart';

// **************************************************************************
// BuiltReduxGenerator
// **************************************************************************

// ignore_for_file: avoid_classes_with_only_static_members
// ignore_for_file: annotate_overrides

class _$AppActions extends AppActions {
  factory _$AppActions() => new _$AppActions._();
  _$AppActions._() : super._();

  final ActionDispatcher<Todo> addTodo =
      new ActionDispatcher<Todo>('AppActions-addTodo');

  @override
  void setDispatcher(Dispatcher dispatcher) {
    addTodo.setDispatcher(dispatcher);
  }
}

class AppActionsNames {
  static final ActionName<Todo> addTodo =
      new ActionName<Todo>('AppActions-addTodo');
}
