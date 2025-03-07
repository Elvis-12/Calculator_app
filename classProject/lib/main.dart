import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Firebase configuration
const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyDkbM4-VlpP35g1avYEHuetERYJaNU5efE",
  authDomain: "mobile-faf6d.firebaseapp.com",
  projectId: "mobile-faf6d",
  storageBucket: "mobile-faf6d.appspot.com",
  messagingSenderId: "518833287961",
  appId: "1:518833287961:web:69fe186c9d95ea9e8c8b88",
  measurementId: "G-5LX9JTKWWJ",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.hasData ? const HomePage() : LoginPage();
        },
      ),
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return (await _auth.signInWithCredential(credential)).user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async => await _auth.signOut();
}

class LoginPage extends StatelessWidget {
  final AuthService _authService = AuthService();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image.asset("assets/google_logo.png", height: 50), // Add Google logo
                const SizedBox(height: 20),
                const Text("Welcome!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    User? user = await _authService.signInWithGoogle();
                    if (user != null) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Sign in with Google"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _pages = [const DashboardPage(), const CalculatorPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? "User"),
              accountEmail: Text(user?.email ?? "Email"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : const AssetImage("assets/default_avatar.png") as ImageProvider,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Dashboard"),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text("Calculator"),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await _authService.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calculator"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Welcome to the Dashboard!", style: TextStyle(fontSize: 18)));
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _output = "0";
  double num1 = 0;
  double num2 = 0;
  String operand = "";

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        num1 = 0;
        num2 = 0;
        operand = "";
      } else if ("+-x/".contains(buttonText)) {
        num1 = double.parse(_output);
        operand = buttonText;
        _output = "0";
      } else if (buttonText == "=") {
        num2 = double.parse(_output);
        if (operand == "+") _output = (num1 + num2).toString();
        if (operand == "-") _output = (num1 - num2).toString();
        if (operand == "x") _output = (num1 * num2).toString();
        if (operand == "/") _output = (num1 / num2).toString();
        operand = "";
      } else {
        _output = _output == "0" ? buttonText : _output + buttonText;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_output, style: const TextStyle(fontSize: 48)),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemCount: 16,
          itemBuilder: (context, index) {
            List<String> buttons = ["7", "8", "9", "/", "4", "5", "6", "x", "1", "2", "3", "-", "C", "0", "=", "+"];
            return ElevatedButton(
              onPressed: () => buttonPressed(buttons[index]),
              child: Text(buttons[index], style: const TextStyle(fontSize: 24)),
            );
          },
        ),
      ],
    );
  }
}
