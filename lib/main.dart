import 'package:citycab/pages/auth/bloc/auth_bloc.dart';
import 'package:citycab/pages/home/home.dart';
import 'package:citycab/ui/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthBloc bloc;

  @override
  void initState() {
    bloc = AuthBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => bloc,
      child: MaterialApp(
        title: 'City Cab',
        theme: CityTheme.theme,
        home: HomePage(),
      ),
    );
  }
}
