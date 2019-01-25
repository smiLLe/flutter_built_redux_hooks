import 'package:built_redux/built_redux.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show useContext, useMemoized, useStream;

class ReduxProvider extends InheritedWidget {
  ReduxProvider({Key key, @required this.store, @required Widget child})
      : super(key: key, child: child);

  final Store store;

  @override
  bool updateShouldNotify(ReduxProvider old) => store != old.store;
}

Store _useReduxStore() {
  final context = useContext();
  final ReduxProvider reduxProvider =
      context.inheritFromWidgetOfExactType(ReduxProvider);

  assert(reduxProvider != null,
      'Store was not found, make sure ReduxProvider is an ancestor of this hook');

  return reduxProvider.store;
}

Actions useReduxActions<Actions extends ReduxActions>() {
  final store = _useReduxStore();

  assert(store.actions is Actions,
      'Actions was not found, make sure generic Actions matches built_redux store.actions');

  return store.actions as Actions;
}

SubState useReduxState<State, SubState>(SubState connect(State state),
    {ignoreChange = false}) {
  final store = _useReduxStore();

  assert(store.state is State,
      'State was not found, make sure generic State matches built_redux store.state');

  SubState _state = connect(store.state as State);

  if (true == ignoreChange) {
    return _state;
  }

  Stream<SubState> stream = useMemoized(() => store.substateStream((state) {
        return connect(state as State);
      }).map((s) => s.next));

  AsyncSnapshot<SubState> data = useStream(
    stream,
    initialData: _state,
  );

  return data.data;
}
