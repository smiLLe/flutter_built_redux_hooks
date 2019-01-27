import 'package:built_redux/built_redux.dart';
import 'package:built_value/built_value.dart' as BV;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show useContext, useMemoized, useStream;

/// Provides a the Redux [Store] to all descendants of this Widget.
/// Make this the root Widget of your app.
/// To connect to the provided store use [useReduxState].
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

/// Returns the store provided by [ReduxProvider].
Store<State, StateBuilder, Actions> useReduxStore<
    State extends BV.Built<State, StateBuilder>,
    StateBuilder extends BV.Builder<State, StateBuilder>,
    Actions extends ReduxActions>() {
  final store = _useReduxStore();

  assert(store is Store<State, StateBuilder, Actions>,
      'Store was not found, make sure generics matches your store provided through ReduxProvider');

  return store as Store<State, StateBuilder, Actions>;
}

/// Returns the actions from your [Store].
Actions useReduxActions<Actions extends ReduxActions>() {
  final store = _useReduxStore();

  assert(store.actions is Actions,
      'Actions was not found, make sure generic Actions matches built_redux store.actions');

  return store.actions as Actions;
}

/// This hook will connect to the [Store] and returns the [SubState] given
/// in [connect].
///
/// Every time the [SubState] changes, the Widget will rebuilt.
/// The only exception is when [ignoreChange] is set to true. This will
/// return the [SubState] whenever the Widget is rebuilding and not when the
/// [SubState] changes.
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
