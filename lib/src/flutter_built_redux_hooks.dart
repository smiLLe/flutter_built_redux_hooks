import 'package:built_redux/built_redux.dart';
import 'package:built_value/built_value.dart' as BV;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;
import 'package:provider/provider.dart';

/// Provides a the Redux [Store] to all descendants of this Widget.
/// Make this the root Widget of your app.
/// To connect to the provided store use [useReduxState].
class ReduxProvider extends StatelessWidget {
  final Store store;
  final Widget child;
  final bool autoDisposeStore;
  ReduxProvider(
      {Key key,
      @required this.store,
      @required this.child,
      this.autoDisposeStore = true})
      : super(key: key);

  static Store of(BuildContext context) => Provider.of<Store>(context);

  @override
  Widget build(BuildContext context) {
    if (false == autoDisposeStore) {
      return Provider<Store>(value: store, child: child);
    }
    return HookProvider<Store>(
      hook: () {
        useEffect(() => () => store.dispose(), [store]);
        return store;
      },
      child: child,
    );
  }
}

Store _useReduxStore() {
  final context = useContext();
  final Store store = ReduxProvider.of(context);

  assert(store != null,
      'Store was not found, make sure ReduxProvider is an ancestor of this hook');

  return store;
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

  Stream<SubState> stream = useMemoized(
      () => store.substateStream((state) {
            return connect(state as State);
          }).map((s) => s.next),
      [store]);

  AsyncSnapshot<SubState> data = useStream(
    stream,
    initialData: _state,
  );

  return data.data;
}

/// Executes the [effect] once, after the widget has built
void useReduxStateOnInitialBuildEffect<State>(
    VoidCallback effect(State state)) {
  final state = useReduxState<State, State>((s) => s, ignoreChange: true);
  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) => effect(state));
  }, []);
}

/// Executes the [effect] whenever the connected [SubState] changed
void useReduxStateOnDidChangeEffect<State, SubState>(
    SubState connect(State state), VoidCallback effect(SubState state)) {
  final state = useReduxState(connect);
  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) => effect(state));
  }, [state]);
}
