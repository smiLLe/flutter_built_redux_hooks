import 'dart:async';

import 'package:built_redux/built_redux.dart';
import 'package:built_value/built_value.dart' as bv;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;
import 'package:provider/provider.dart';

/// Provides a the Redux [Store] to all descendants of this Widget.
/// Make this the root Widget of your app.
/// To connect to the provided store use [useReduxState].
class ReduxProvider extends StatelessWidget {
  /// Redux [Store]
  final Store store;

  /// Child
  final Widget child;

  /// Should [Store] be disposed if a new [Store] was passed
  final bool autoDisposeStore;

  /// Creates [ReduxProvider] and passes store down to all descendants
  ReduxProvider(
      {Key key,
      @required this.store,
      @required this.child,
      this.autoDisposeStore = true})
      : super(key: key);

  /// Get Redux Store from context
  static Store of(BuildContext context) => Provider.of<Store>(context);

  @override
  Widget build(BuildContext context) {
    if (false == autoDisposeStore) {
      return Provider<Store>(value: store, child: child);
    }
    return HookProvider<Store>(
      hook: () {
        useEffect(() => store.dispose, <dynamic>[store]);
        return store;
      },
      child: child,
    );
  }
}

Store _useReduxStore() {
  final context = useContext();
  final store = ReduxProvider.of(context);

  assert(store != null,
      'Store was not found, make sure ReduxProvider is an ancestor of this hook');

  return store;
}

/// Returns the store provided by [ReduxProvider].
Store<State, StateBuilder, Actions> useReduxStore<
    State extends bv.Built<State, StateBuilder>,
    StateBuilder extends bv.Builder<State, StateBuilder>,
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
    {bool ignoreChange = false}) {
  final store = _useReduxStore();

  assert(store.state is State,
      'State was not found, make sure generic State matches built_redux store.state');

  final _state = connect(store.state as State);

  if (true == ignoreChange) {
    return _state;
  }

  final stream = useMemoized(
      () => store.substateStream((state) {
            return connect(state as State);
          }).map((s) => s.next),
      <dynamic>[store]);

  final data = useStream(
    stream,
    initialData: _state,
  );

  return data.data;
}

/// Executes the [effect] once, after the widget has built
void useReduxStateOnInitialBuildEffect<State, SubState>(
    SubState connect(State state), VoidCallback effect(SubState state)) {
  useReduxStateEffect<State, SubState>(connect, onInitial: effect);
}

/// Executes the [effect] whenever the connected [SubState] changed
void useReduxStateOnDidChangeEffect<State, SubState>(
    SubState connect(State state), VoidCallback effect(SubState state)) {
  useReduxStateEffect<State, SubState>(connect, onDidChange: effect);
}

/// Executes callbacks whenever state changes
void useReduxStateEffect<State, SubState>(
  SubState connect(State state), {
  VoidCallback onDidChange(SubState state),
  VoidCallback onInitial(SubState state),
  VoidCallback onDispose(),
}) {
  Hook.use(_ReduxStateCallbacksHook(
    connect,
    onDidChange: onDidChange,
    onInitial: onInitial,
    onDispose: onDispose,
  ));
}

class _ReduxStateCallbacksHook<State, SubState> extends Hook<void> {
  final SubState Function(State state) connect;

  final void Function(SubState state) onInitial;
  final void Function(SubState state) onDidChange;
  final void Function() onDispose;

  const _ReduxStateCallbacksHook(this.connect,
      {this.onInitial, this.onDidChange, this.onDispose});

  @override
  _ReduxStateCallbacksHookState<State, SubState> createState() =>
      _ReduxStateCallbacksHookState<State, SubState>();
}

class _ReduxStateCallbacksHookState<State, SubState>
    extends HookState<void, _ReduxStateCallbacksHook<State, SubState>> {
  Store _store;
  StreamSubscription _subscription;

  void _subscribe() {
    _store = ReduxProvider.of(context);

    if (null != hook.onInitial) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => hook.onInitial(hook.connect(_store.state as State)));
    }

    if (null != hook.onDidChange) {
      _subscription = _store
          .substateStream((state) => hook.connect(state as State))
          .map((s) => s.next)
          .listen((s) => WidgetsBinding.instance
              .addPostFrameCallback((_) => hook.onDidChange(s)));
    }
  }

  void _unsubscribe() {
    if (null != _subscription) {
      _subscription.cancel();
      _subscription = null;
    }

    if (null != hook.onDispose) {
      hook.onDispose();
    }
  }

  @override
  void initHook() {
    super.initHook();
    _subscribe();
  }

  @override
  void dispose() {
    super.dispose();
    _unsubscribe();
  }

  @override
  void build(BuildContext context) {}
}
