import 'package:built_collection/built_collection.dart';
import 'package:built_redux/built_redux.dart';
import 'package:example/redux/app_actions.dart';
import 'package:example/redux/app_state.dart';
import 'package:flutter/material.dart';
import 'package:example/redux/app_reducer.dart';
import 'package:flutter_built_redux_hooks/flutter_built_redux_hooks.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;

final store = Store<AppState, AppStateBuilder, AppActions>(
    appReducer, AppState(), AppActions());

void main() => runApp(TodoApp());

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ReduxProvider(
      store: store,
      child: MaterialApp(
        home: TodoScreen(),
      ),
    );
  }
}

class TodoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AddTodo(),
            TodosList(),
          ],
        ),
      ),
    );
  }
}

class AddTodo extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final actions = useReduxActions<AppActions>();
    final todos = useReduxState<AppState, BuiltList<Todo>>((s) => s.todos);
    return Column(
      children: <Widget>[
//        TextFormField(),
        RaisedButton(
          child: Text('Add Todo'),
          onPressed: () {
            final todo = Todo((b) => b.title = 'New Todo ${todos.length}');
            actions.addTodo(todo);
          },
        ),
      ],
    );
  }
}

class TodosList extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final todos = useReduxState<AppState, BuiltList<Todo>>((s) => s.todos);
    useReduxStateOnInitialBuildEffect<AppState, BuiltList<Todo>>((s) => s.todos,
        (s) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Initial Snackbar')));
    });
    useReduxStateOnDidChangeEffect<AppState, BuiltList<Todo>>((s) => s.todos,
        (s) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(s.last.title)));
    });

    return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos.elementAt(index);
          return ListTile(
            title: Text(todo.title),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text('Second page'),
                      ),
                    ),
              ));
            },
          );
        });
  }
}
