import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

// =======================================================================
// SCREEN 1: LOGIN / INPUT SCREEN
// =======================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text('Session 07: Login Form'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person, size: 70, color: Colors.deepPurple),
              const SizedBox(height: 16),
              const Text(
                'Welcome! Please Log In',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // =======================================================
              // TODO 1: Attach _nameController to this TextField
              // =======================================================
              TextField(controller: _nameController,
                // HINT: Add controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Enter your name',
                  hintText: 'e.g. Iam Supercool',
                  prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // =======================================================
              // TODO 2, 3, and 4: Handle Input, Validation & Navigation
              // =======================================================
              ElevatedButton(
                onPressed: () {
                  String userName = _nameController.text;
                  if (userName.isEmpty){}
                  else {Navigator.push(
                    context, MaterialPageRoute(
      builder: (context) => const DashboardScreen(),
    ),
  );
}
                  
                  // TODO 2: Extract the user input text using .text
                  // String userName = _nameController.text;

                  // TODO 3: Write an if-else check:
                  // If userName.isEmpty, show a red warning SnackBar.
                  // Otherwise (else block), execute TODO 4!

                  // TODO 4: Inside the else block, use Navigator.push()
                  // to navigate forward to DashboardScreen()!
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text('Log In ➔', style: TextStyle(fontSize: 16)),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// SCREEN 2: DASHBOARD / WELCOME SCREEN
// =======================================================================
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.teal),
            const SizedBox(height: 16),
            const Text(
              'Login Successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Welcome to your Dashboard'),
            const SizedBox(height: 32),

            // =======================================================
            // TODO 5: Make this button go back using Navigator.pop
            // =======================================================
            ElevatedButton(
              onPressed: () {Navigator.pop(context);
                // TODO 5: Add Navigator.pop(context); here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('⬅ Log Out / Go Back'),
            ),

          ],
        ),
      ),
    );
  }
}