import 'package:built_redux/built_redux.dart' as BR;
import 'package:flutter/material.dart';
import 'package:flutter_built_redux_hooks/flutter_built_redux_hooks.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'test_models.dart';

Key exampleHookWidgetKey = Key('exampleHookWidgetKey');
Key textCountKey = Key('textCountKey');
Key incrementButtonKey = Key('incrementButtonKey');
Key doNotChangeStateButtonKey = Key('doNothingButtonKey');

class Provider extends StatelessWidget {
  final BR.Store<Counter, CounterBuilder, CounterActions> store;
  final Widget child;
  const Provider({Key key, this.store, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ReduxProvider(
      store: store,
      child: child,
    ));
  }
}

// ignore: must_be_immutable
class Example extends HookWidget {
  int numBuilds = 0;

  Example() : super(key: exampleHookWidgetKey);

  @override
  Widget build(BuildContext context) {
    Counter state = useReduxState<Counter, Counter>((s) => s);
    CounterActions actions = useReduxActions<CounterActions>();

    numBuilds++;

    return Column(
      children: <Widget>[
        new RaisedButton(
          onPressed: actions.increment,
          child: new Text('Increment'),
          key: incrementButtonKey,
        ),
        new RaisedButton(
          onPressed: actions.doesNotChangeState,
          child: new Text('doNothing'),
          key: doNotChangeStateButtonKey,
        ),
        Text(
          'Count: ${state.count}',
          key: textCountKey,
        ),
      ],
    );
  }
}
