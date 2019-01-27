import 'package:built_redux/built_redux.dart';
import 'package:example/redux/app_actions.dart';
import 'package:example/redux/app_state.dart';

void appReducer(
    AppState prevState, Action<dynamic> action, AppStateBuilder builder) {
  if (action.name == AppActionsNames.addTodo.name) {
    builder.todos.add(action.payload);
  }
}
