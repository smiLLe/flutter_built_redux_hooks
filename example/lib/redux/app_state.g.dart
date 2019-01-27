// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppState extends AppState {
  @override
  final BuiltList<Todo> todos;

  factory _$AppState([void updates(AppStateBuilder b)]) =>
      (new AppStateBuilder()..update(updates)).build();

  _$AppState._({this.todos}) : super._() {
    if (todos == null) {
      throw new BuiltValueNullFieldError('AppState', 'todos');
    }
  }

  @override
  AppState rebuild(void updates(AppStateBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  AppStateBuilder toBuilder() => new AppStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppState && todos == other.todos;
  }

  @override
  int get hashCode {
    return $jf($jc(0, todos.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('AppState')..add('todos', todos))
        .toString();
  }
}

class AppStateBuilder implements Builder<AppState, AppStateBuilder> {
  _$AppState _$v;

  ListBuilder<Todo> _todos;
  ListBuilder<Todo> get todos => _$this._todos ??= new ListBuilder<Todo>();
  set todos(ListBuilder<Todo> todos) => _$this._todos = todos;

  AppStateBuilder();

  AppStateBuilder get _$this {
    if (_$v != null) {
      _todos = _$v.todos?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppState other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$AppState;
  }

  @override
  void update(void updates(AppStateBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$AppState build() {
    _$AppState _$result;
    try {
      _$result = _$v ?? new _$AppState._(todos: todos.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'todos';
        todos.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'AppState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$Todo extends Todo {
  @override
  final String title;

  factory _$Todo([void updates(TodoBuilder b)]) =>
      (new TodoBuilder()..update(updates)).build();

  _$Todo._({this.title}) : super._() {
    if (title == null) {
      throw new BuiltValueNullFieldError('Todo', 'title');
    }
  }

  @override
  Todo rebuild(void updates(TodoBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  TodoBuilder toBuilder() => new TodoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Todo && title == other.title;
  }

  @override
  int get hashCode {
    return $jf($jc(0, title.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Todo')..add('title', title))
        .toString();
  }
}

class TodoBuilder implements Builder<Todo, TodoBuilder> {
  _$Todo _$v;

  String _title;
  String get title => _$this._title;
  set title(String title) => _$this._title = title;

  TodoBuilder();

  TodoBuilder get _$this {
    if (_$v != null) {
      _title = _$v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Todo other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Todo;
  }

  @override
  void update(void updates(TodoBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Todo build() {
    final _$result = _$v ?? new _$Todo._(title: title);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
