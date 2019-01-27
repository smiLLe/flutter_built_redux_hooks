import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';

part 'app_state.g.dart';

abstract class AppState implements Built<AppState, AppStateBuilder> {
  BuiltList<Todo> get todos;

  AppState._();
  factory AppState([updates(AppStateBuilder b)]) =>
      _$AppState((b) => b..todos = BuiltList<Todo>.from([]).toBuilder());
}

abstract class Todo implements Built<Todo, TodoBuilder> {
  String get title;
  Todo._();
  factory Todo([updates(TodoBuilder b)]) = _$Todo;
}
