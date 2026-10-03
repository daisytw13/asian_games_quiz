import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const AsianGamesQuizApp());
}

class AsianGamesQuizApp extends StatelessWidget {
  const AsianGamesQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asian Games Country Challenge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// Country Data
// ============================================================

class Country {
  final String id;
  final String name;
  final String flag;
  final String region;

  // Position on our demo world map.
  // These are percentages from the left/top.
  final double mapX;
  final double mapY;

  const Country({
    required this.id,
    required this.name,
    required this.flag,
    required this.region,
    required this.mapX,
    required this.mapY,
  });
}

const List<Country> countries = [
  Country(
    id: 'japan',
    name: 'Japan',
    flag: '🇯🇵',
    region: 'East Asia',
    mapX: 82,
    mapY: 43,
  ),
  Country(
    id: 'china',
    name: 'China',
    flag: '🇨🇳',
    region: 'East Asia',
    mapX: 69,
    mapY: 43,
  ),
];

// ============================================================
// Home Screen
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🌏',
                  style: TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Asian Games',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Country Challenge',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Test your knowledge of flags and geography!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QuizScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'START GAME',
                      style: TextStyle(fontSize: 20),
                    ),
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

// ============================================================
// Quiz Screen
// ============================================================

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;

  int flagScore = 0;
  int mapScore = 0;

  bool flagAnswered = false;
  bool mapAnswered = false;

  String? selectedFlag;
  String? mapResult;

  late List<Country> flagOptions;

  @override
  void initState() {
    super.initState();
    generateFlagOptions();
  }

  Country get currentCountry => countries[currentQuestion];

  void generateFlagOptions() {
    final current = currentCountry;

    List<Country> options = countries
        .where((country) => country.id != current.id)
        .toList();

    options.add(current);
    options.shuffle(Random());

    // This demo only has 2 countries.
    // We duplicate a harmless option to create 3 visual choices.
    while (options.length < 3) {
      options.add(options[0]);
    }

    flagOptions = options.take(3).toList();
  }

  void selectFlag(Country country) {
    if (flagAnswered) return;

    setState(() {
      flagAnswered = true;
      selectedFlag = country.id;

      if (country.id == currentCountry.id) {
        flagScore++;
      }
    });
  }

  void selectMap(double x, double y) {
    if (mapAnswered) return;

    final targetX = currentCountry.mapX;
    final targetY = currentCountry.mapY;

    final dx = x - targetX;
    final dy = y - targetY;

    final distance = sqrt(dx * dx + dy * dy);

    // Demo tolerance.
    const tolerance = 8.0;

    setState(() {
      mapAnswered = true;

      if (distance <= tolerance) {
        mapScore++;
        mapResult = 'correct';
      } else {
        mapResult = 'wrong';
      }
    });
  }

  void nextQuestion() {
    if (!flagAnswered || !mapAnswered) return;

    if (currentQuestion == countries.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            flagScore: flagScore,
            mapScore: mapScore,
            totalQuestions: countries.length,
          ),
        ),
      );
      return;
    }

    setState(() {
      currentQuestion++;

      flagAnswered = false;
      mapAnswered = false;

      selectedFlag = null;
      mapResult = null;

      generateFlagOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final country = currentCountry;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${currentQuestion + 1} / ${countries.length}',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (currentQuestion + 1) / countries.length,
              ),

              const SizedBox(height: 24),

              Text(
                country.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // Part 1 - Flag
              // ------------------------------------------------

              const Text(
                '1. Which flag belongs to this country?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: flagOptions.map((option) {
                  final isSelected = selectedFlag == option.id;
                  final isCorrect = option.id == country.id;

                  Color? background;

                  if (flagAnswered) {
                    if (isCorrect) {
                      background = Colors.green.shade100;
                    } else if (isSelected) {
                      background = Colors.red.shade100;
                    }
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => selectFlag(option),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              option.flag,
                              style: const TextStyle(fontSize: 45),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (flagAnswered) ...[
                const SizedBox(height: 12),
                Text(
                  selectedFlag == country.id
                      ? '✓ Correct!'
                      : '✕ Incorrect. The correct flag is ${country.flag}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: selectedFlag == country.id
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],

              const SizedBox(height: 35),

              // ------------------------------------------------
              // Part 2 - Map
              // ------------------------------------------------

              const Text(
                '2. Where is this country?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              DemoWorldMap(
                countries: countries,
                targetCountry: currentCountry,
                answered: mapAnswered,
                result: mapResult,
                onTap: selectMap,
              ),

              const SizedBox(height: 15),

              if (mapAnswered)
                Text(
                  mapResult == 'correct'
                      ? '✓ Correct location!'
                      : '✕ Incorrect location',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: mapResult == 'correct'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),

              const SizedBox(height: 25),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      flagAnswered && mapAnswered ? nextQuestion : null,
                  child: Text(
                    currentQuestion == countries.length - 1
                        ? 'FINISH'
                        : 'NEXT COUNTRY',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Demo World Map
// ============================================================

class DemoWorldMap extends StatelessWidget {
  final List<Country> countries;
  final Country targetCountry;
  final bool answered;
  final String? result;
  final Function(double x, double y) onTap;

  const DemoWorldMap({
    super.key,
    required this.countries,
    required this.targetCountry,
    required this.answered,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapDown: (details) {
              final x =
                  details.localPosition.dx / constraints.maxWidth * 100;

              final y =
                  details.localPosition.dy / constraints.maxHeight * 100;

              onTap(x, y);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blueGrey,
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Simple continents.
                  Positioned(
                    left: 30,
                    top: 60,
                    child: _continent(
                      width: 130,
                      height: 100,
                      label: 'N. America',
                    ),
                  ),

                  Positioned(
                    left: 160,
                    top: 90,
                    child: _continent(
                      width: 80,
                      height: 150,
                      label: 'S. America',
                    ),
                  ),

                  Positioned(
                    left: 340,
                    top: 50,
                    child: _continent(
                      width: 100,
                      height: 100,
                      label: 'Europe',
                    ),
                  ),

                  Positioned(
                    left: 430,
                    top: 100,
                    child: _continent(
                      width: 150,
                      height: 120,
                      label: 'Asia',
                    ),
                  ),

                  Positioned(
                    left: 350,
                    top: 180,
                    child: _continent(
                      width: 110,
                      height: 120,
                      label: 'Africa',
                    ),
                  ),

                  Positioned(
                    right: 20,
                    top: 190,
                    child: _continent(
                      width: 100,
                      height: 70,
                      label: 'Australia',
                    ),
                  ),

                  if (answered)
                    Positioned(
                      left: targetCountry.mapX / 100 *
                          constraints.maxWidth -
                          15,
                      top: targetCountry.mapY / 100 *
                          constraints.maxHeight -
                          15,
                      child: Text(
                        targetCountry.flag,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),

                  const Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Text(
                      'Tap the map',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _continent({
    required double width,
    required double height,
    required String label,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.green.shade300,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Result Screen
// ============================================================

class ResultScreen extends StatelessWidget {
  final int flagScore;
  final int mapScore;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.flagScore,
    required this.mapScore,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final totalScore = flagScore + mapScore;
    final maxScore = totalQuestions * 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Result'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🏆',
                style: TextStyle(fontSize: 80),
              ),

              const SizedBox(height: 20),

              const Text(
                'Game Complete!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                '$totalScore / $maxScore',
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                '🇺🇳 Flags: $flagScore / $totalQuestions',
                style: const TextStyle(fontSize: 20),
              ),

              const SizedBox(height: 10),

              Text(
                '🗺️ Locations: $mapScore / $totalQuestions',
                style: const TextStyle(fontSize: 20),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'PLAY AGAIN',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}