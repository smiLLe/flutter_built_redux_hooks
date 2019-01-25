[![Build Status](https://travis-ci.org/smiLLe/flutter_built_redux_hooks.svg?branch=master)](https://travis-ci.org/smiLLe/flutter_built_redux_hooks)

## Usage

`useReduxActions` usage:

```dart
HookBuilder(
  builder: (context) {
    MyActions actions = useReduxActions<MyActions>();

    return RaisedButton(
        onPressed: () => actions.someAction(),
        child: new Text('dispatch action'),
    ),
  },
)
```

`useReduxActions` usage:

```dart
HookBuilder(
  builder: (context) {
    SubState sub = useReduxState<State, SubState>((s) => s.sub);
    return Text(sub.textProp);
  },
)
```
