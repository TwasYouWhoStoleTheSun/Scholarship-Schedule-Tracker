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
      home: ScoreScreen(),
    );
  }
}

// =======================================================================
// SCREEN 1: SCORE SCREEN (STATEFUL WIDGET - PAPAN TULIS BISA DIUBAH)
// =======================================================================
class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  // Kotak memori (Variable) untuk menyimpan angka skor saat ini
  int currentScore = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text('Session 08: Game Scorekeeper'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Points Scored:',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // Menampilkan angka skor yang ada di dalam variabel currentScore
            Text(
              '$currentScore',
              style: const TextStyle(
                fontSize: 70,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 30),

            // Baris berisi tombol Minus dan Plus
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TOMBOL MINUS (-1)
                ElevatedButton(
                  onPressed: () {
                    if (currentScore > 0) {
                       setState(() {
                         currentScore = currentScore - 1;
                       });
                     }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('-1 Point', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 20),

                // TOMBOL PLUS (+1)
                ElevatedButton(
                  onPressed: () {
                    // TODO 2: Tambahkan currentScore dengan 1 di dalam setState.
                    // HINT:
                    // setState(() {
                    //   currentScore = currentScore + 1;
                    // });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('+1 Point', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // TOMBOL SELESAI & PINDAH HALAMAN
            ElevatedButton(
              onPressed: () {
                // TODO 3: Pindah ke ResultScreen sambil membawa variabel currentScore.
                // HINT:
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ResultScreen(finalScore: currentScore),
                //   ),
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              child: const Text('Finish Game and View Result ->', style: TextStyle(fontSize: 16)),
            ),

          ],
        ),
      ),
    );
  }
}

// =======================================================================
// SCREEN 2: RESULT SCREEN (MENERIMA DAN MENAMPILKAN DATA)
// =======================================================================
class ResultScreen extends StatelessWidget {
  // Tempat menampung data skor yang dikirimkan dari Screen 1
  final int finalScore;

  const ResultScreen({super.key, required this.finalScore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('Game Results'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, size: 90, color: Colors.teal),
            const SizedBox(height: 16),
            const Text(
              'Congratulations!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // TODO 4: Tampilkan nilai finalScore di dalam Text widget berikut
            Text(
              'Your Final Score: ', // HINT: Tambahkan $finalScore di samping teks
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 35),

            // TOMBOL KEMBALI
            ElevatedButton(
              onPressed: () {
                // TODO 5: Gunakan Navigator.pop untuk kembali ke Screen 1
                // HINT: Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('<- Play Again'),
            ),

          ],
        ),
      ),
    );
  }
}