import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mus_building/firebase_options.dart';
import 'sign_in_page.dart'; // Import your sign-in page
import 'main_screen.dart'; // Import your main screen page
import 'splash_screen.dart'; // Import your splash screen
import 'materials_page.dart'; // Import your materials page
import 'project_details_page.dart'; // Import your project details page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: '/splash', // Define the initial route
      routes: {
        '/splash': (context) => SplashScreen(), // Route for splash screen
        '/sign_in': (context) => SignInPage(), // Route for sign-in page
        '/main': (context) => MainScreen(), // Route for main screen
        '/materials': (context) => MaterialsPage(),
        '/project_details': (context) => ProjectDetailsPage(projectId: ModalRoute.of(context)!.settings.arguments as String),
        '/': (context) => MainScreen(), // Default route to the main screen
      },
      // Optionally, handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('404'),
            ),
            body: Center(
              child: Text('Page not found!'),
            ),
          ),
        );
      },
    );
  }
}
