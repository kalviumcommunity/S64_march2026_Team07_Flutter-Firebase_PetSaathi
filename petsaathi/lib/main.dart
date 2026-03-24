import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/landing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetSaathi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Rapido style theme (Yellow/black/white)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF9C80E), // A vibrant yellow
          primary: const Color(0xFFF9C80E),
          secondary: Colors.black87,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9C80E),
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF9C80E),
            foregroundColor: Colors.black87,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      home: const LandingScreen(),
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