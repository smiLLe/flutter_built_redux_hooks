import 'package:built_redux/built_redux.dart' as BR;
import 'package:flutter/material.dart';
import 'package:flutter_built_redux_hooks/flutter_built_redux_hooks.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:built_value_test/matcher.dart';

import 'test_models.dart';
import 'test_widgets.dart';

void main() {
  BR.Store<Counter, CounterBuilder, CounterActions> store;

  setUp(() {
    store = createStore();
  });

  tearDown(() async {
    await store.dispose();
  });

  testWidgets('useReduxStore', (WidgetTester tester) async {
    BR.Store<Counter, CounterBuilder, CounterActions> _store;

    await tester.pumpWidget(Provider(
      store: store,
      child: HookBuilder(
        builder: (context) {
          _store = useReduxStore<Counter, CounterBuilder, CounterActions>();
          return Container();
        },
      ),
    ));

    expect(store, _store);
  });

  testWidgets('useReduxActions', (WidgetTester tester) async {
    CounterActions actions;

    await tester.pumpWidget(Provider(
      store: store,
      child: HookBuilder(
        builder: (context) {
          actions = useReduxActions();
          return Container();
        },
      ),
    ));

    expect(actions, store.actions);
  });

  group('useReduxState', () {
    testWidgets('get complete state', (WidgetTester tester) async {
      Counter state;

      await tester.pumpWidget(Provider(
        store: store,
        child: HookBuilder(
          builder: (context) {
            state = useReduxState<Counter, Counter>((s) => s);
            return Container();
          },
        ),
      ));

      expect(state, equalsBuilt(createStore().state));
    });

    testWidgets('get substate', (WidgetTester tester) async {
      int state;

      await tester.pumpWidget(Provider(
        store: store,
        child: HookBuilder(
          builder: (context) {
            state = useReduxState<Counter, int>((s) => s.count);
            return Container();
          },
        ),
      ));

      expect(state, createStore().state.count);
    });

    testWidgets('get correct state after state changed',
        (WidgetTester tester) async {
      Counter state;
      final initialState = store.state;

      await tester.pumpWidget(Provider(
        store: store,
        child: HookBuilder(
          builder: (context) {
            state = useReduxState<Counter, Counter>((s) => s);
            final actions = useReduxActions<CounterActions>();

            return Container(
              child: RaisedButton(
                onPressed: actions.increment,
                child: new Text('Increment'),
                key: incrementButtonKey,
              ),
            );
          },
        ),
      ));

      expect(state, equalsBuilt(initialState));

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();

      expect(state, equalsBuilt(Counter().rebuild((b) => b..count = 1)));
    });

    testWidgets('rebuild count', (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(Provider(
        store: store,
        child: HookBuilder(
          builder: (context) {
            useReduxState<Counter, Counter>((s) => s);
            final actions = useReduxActions<CounterActions>();

            buildCount++;

            return Container(
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: actions.increment,
                    child: new Text('Increment'),
                    key: incrementButtonKey,
                  ),
                  RaisedButton(
                    onPressed: actions.doesNotChangeState,
                    child: new Text('do not change state'),
                    key: doNotChangeStateButtonKey,
                  )
                ],
              ),
            );
          },
        ),
      ));

      expect(buildCount, 1);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();

      expect(buildCount, 2);

      await tester.tap(find.byKey(doNotChangeStateButtonKey));
      await tester.pump();

      expect(buildCount, 2);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();

      expect(buildCount, 3);
    });

    testWidgets('ignoreChange - do not rebuild widget on state change',
        (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(Provider(
        store: store,
        child: HookBuilder(
          builder: (context) {
            useReduxState<Counter, Counter>((s) => s, ignoreChange: true);
            final actions = useReduxActions<CounterActions>();

            buildCount++;

            return Container(
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: actions.increment,
                    child: new Text('Increment'),
                    key: incrementButtonKey,
                  ),
                  RaisedButton(
                    onPressed: actions.doesNotChangeState,
                    child: new Text('do not change state'),
                    key: doNotChangeStateButtonKey,
                  )
                ],
              ),
            );
          },
        ),
      ));

      expect(buildCount, 1);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();

      expect(buildCount, 1);

      await tester.tap(find.byKey(doNotChangeStateButtonKey));
      await tester.pump();

      expect(buildCount, 1);
    });

    testWidgets(
        'ignoreChange - get correct state if widget rebuilds for other reasons',
        (WidgetTester tester) async {
      int buildCount = 0;
      Counter state;

      await tester.pumpWidget(Provider(
        store: store,
        child: HookBuilder(
          builder: (context) {
            state =
                useReduxState<Counter, Counter>((s) => s, ignoreChange: true);
            final counter = useState(0);
            final actions = useReduxActions<CounterActions>();

            buildCount++;

            return Container(
              child: Column(
                children: <Widget>[
                  FlatButton(
                    onPressed: () => counter.value += 1,
                    child: new Text('Increment counter'),
                  ),
                  RaisedButton(
                    onPressed: actions.increment,
                    child: new Text('Increment'),
                    key: incrementButtonKey,
                  ),
                ],
              ),
            );
          },
        ),
      ));

      expect(buildCount, 1);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();

      expect(buildCount, 1);
      expect(state.count, 0);

      await tester.tap(find.byType(FlatButton));
      await tester.pump();

      expect(buildCount, 2);
      expect(state.count, 1);
    });
  });

  group('useReduxStateOnInitialBuildEffect', () {
    testWidgets('execution order', (WidgetTester tester) async {
      List<String> list = [];

      await tester.pumpWidget(Provider(
        store: store,
        child: HookBuilder(
          builder: (context) {
            useReduxStateOnInitialBuildEffect<Counter, Counter>((s) => s,
                (state) {
              list.add('b');
            });

            list.add('a');
            return Container();
          },
        ),
      ));

      expect(list, ['a', 'b']);
    });

    testWidgets('executes only once', (WidgetTester tester) async {
      List<String> list = [];

      Widget widget() {
        return Provider(
          store: store,
          child: HookBuilder(
            builder: (context) {
              useReduxStateOnInitialBuildEffect<Counter, Counter>((s) => s,
                  (state) {
                list.add('b');
              });

              list.add('a');
              return Container();
            },
          ),
        );
      }

      await tester.pumpWidget(widget());
      expect(list, ['a', 'b']);

      await tester.pumpWidget(widget());
      expect(list, ['a', 'b', 'a']);

      await tester.pumpWidget(widget());
      expect(list, ['a', 'b', 'a', 'a']);
    });
  });

  group('useReduxStateOnDidChangeEffect', () {
    testWidgets('count builds', (WidgetTester tester) async {
      int didChange = 0;

      await tester.pumpWidget(Provider(
        store: store,
        child: HookBuilder(
          builder: (context) {
            useReduxStateOnDidChangeEffect<Counter, Counter>((s) => s, (s) {
              didChange++;
            });
            final actions = useReduxActions<CounterActions>();

            return Container(
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: actions.increment,
                    child: new Text('Increment'),
                    key: incrementButtonKey,
                  ),
                ],
              ),
            );
          },
        ),
      ));
      expect(didChange, 0);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();
      expect(didChange, 1);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();
      expect(didChange, 2);
    });

    testWidgets('doest not rebuild widget', (WidgetTester tester) async {
      int didChange = 0;

      await tester.pumpWidget(Provider(
        store: store,
        child: HookBuilder(
          builder: (context) {
            final actions = useReduxActions<CounterActions>();
            useReduxStateOnDidChangeEffect<Counter, Counter>((s) => s, (s) {
              didChange++;
            });

            return Container(
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: actions.increment,
                    child: new Text('Increment $didChange'),
                    key: incrementButtonKey,
                  ),
                ],
              ),
            );
          },
        ),
      ));
      expect(didChange, 0);
      expect(tester.firstWidget<Text>(find.byType(Text)).data, 'Increment 0');

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();
      expect(didChange, 1);
      expect(tester.firstWidget<Text>(find.byType(Text)).data, 'Increment 0');

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();
      expect(didChange, 2);
      expect(tester.firstWidget<Text>(find.byType(Text)).data, 'Increment 0');
    });
  });

  group('useReduxStateCallbacksEffect', () {
    testWidgets('correct number of callback', (WidgetTester tester) async {
      int didChange = 0;

      await tester.pumpWidget(Provider(
        store: store,
        child: HookBuilder(
          builder: (context) {
            final actions = useReduxActions<CounterActions>();
            useReduxStateEffect<Counter, Counter>((s) => s, onInitial: (s) {
              didChange++;
            }, onDidChange: (s) {
              didChange++;
            });

            return Container(
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: actions.increment,
                    child: new Text('Increment'),
                    key: incrementButtonKey,
                  ),
                ],
              ),
            );
          },
        ),
      ));
      expect(didChange, 1);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();
      expect(didChange, 2);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();
      expect(didChange, 3);
    });

    testWidgets('callback order', (WidgetTester tester) async {
      List<String> order = [];

      Widget widget() {
        return Provider(
          store: store,
          child: HookBuilder(
            builder: (context) {
              final actions = useReduxActions<CounterActions>();
              useReduxStateEffect<Counter, Counter>((s) => s, onInitial: (s) {
                order.add('initial');
              }, onDidChange: (s) {
                order.add('didChange');
              }, onDispose: () {
                order.add('dispose');
              });

              return Container(
                child: Column(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: actions.increment,
                      child: new Text('Increment'),
                      key: incrementButtonKey,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }

      await tester.pumpWidget(widget());
      expect(order, ['initial']);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();
      expect(order, ['initial', 'didChange']);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();
      expect(order, ['initial', 'didChange', 'didChange']);

      await tester.pumpWidget(SizedBox());
      expect(order, ['initial', 'didChange', 'didChange', 'dispose']);

      await tester.pumpWidget(widget());
      expect(
          order, ['initial', 'didChange', 'didChange', 'dispose', 'initial']);

      await tester.pump();
      expect(
          order, ['initial', 'didChange', 'didChange', 'dispose', 'initial']);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pumpWidget(widget());
      expect(order, [
        'initial',
        'didChange',
        'didChange',
        'dispose',
        'initial',
        'didChange'
      ]);

      await tester.pumpWidget(SizedBox());
      expect(order, [
        'initial',
        'didChange',
        'didChange',
        'dispose',
        'initial',
        'didChange',
        'dispose'
      ]);
    });

    testWidgets('doest not rebuild widget', (WidgetTester tester) async {
      int numBuilds = 0;

      await tester.pumpWidget(Provider(
        store: store,
        child: HookBuilder(
          builder: (context) {
            numBuilds++;
            final actions = useReduxActions<CounterActions>();
            useReduxStateEffect<Counter, Counter>((s) => s,
                onInitial: (s) {}, onDidChange: (s) {});

            return Container(
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: actions.increment,
                    child: new Text('Increment'),
                    key: incrementButtonKey,
                  ),
                ],
              ),
            );
          },
        ),
      ));
      expect(numBuilds, 1);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();
      expect(numBuilds, 1);

      await tester.tap(find.byKey(incrementButtonKey));
      await tester.pump();
      expect(numBuilds, 1);
    });
  });
}
