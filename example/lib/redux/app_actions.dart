import 'package:built_redux/built_redux.dart';
import 'package:example/redux/app_state.dart';

part 'app_actions.g.dart';

abstract class AppActions extends ReduxActions {
  AppActions._();
  factory AppActions() => new _$AppActions();
  ActionDispatcher<Todo> addTodo;
}
