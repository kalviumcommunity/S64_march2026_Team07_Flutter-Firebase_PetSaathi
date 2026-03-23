import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
// import 'screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Root widget of the PetSaathi application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetSaathi',
      theme: ThemeData(
        // Theme configuration for the PetSaathi app
        // This controls colors, typography, and visual styling
        // across the entire application.
        //
        // TRY THIS: Change the seedColor to Colors.teal or Colors.green
        // and perform hot reload to see the theme update instantly.
        //
        // Flutter’s hot reload allows UI updates without restarting
        // the entire application, which helps speed up development.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This represents the main screen of the PetSaathi application.
  // In the full implementation, this would be the entry point to
  // features like discovering walkers, booking caregivers, and
  // managing pet profiles.

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // setState tells Flutter that the UI needs to be rebuilt.
      // In the actual PetSaathi application, this mechanism would
      // be used to update booking requests, chat messages, or
      // pet activity updates in real time.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The build method is called whenever setState triggers a UI update.
    // Flutter efficiently rebuilds only the necessary widgets to keep
    // the interface responsive and smooth.

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        // This demo screen represents a placeholder for the
        // PetSaathi dashboard where users will interact with
        // features such as booking a walker or viewing pet details.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to PetSaathi!\nYour companion for reliable pet care.',
            ),
            const SizedBox(height: 20),
            const Text('Demo interaction counter:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Demo Interaction',
        child: const Icon(Icons.pets),
      ),
    );
  }
}