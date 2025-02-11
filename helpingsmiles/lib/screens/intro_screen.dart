import 'package:flutter/material.dart';
import 'login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _introData = [
    {
      "title": "Welcome to Helping Smiles",
      "description": "Connecting volunteers with those in need.",
      "image": "lib/assets/intro1.png",
    },
    {
      "title": "Our Mission",
      "description": "Bringing joy and support to communities.",
      "image": "lib/assets/intro2.png",
    },
    {
      "title": "Our Vision",
      "description": "Making volunteering easier than ever.",
      "image": "lib/assets/intro3.png",
    },
  ];

  void _nextPage() {
    if (_currentPage < _introData.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _introData.length,
                  itemBuilder: (_, index) => _buildPageContent(_introData[index]),
                ),
              ),
              const SizedBox(height: 20),
              _buildPageIndicator(),
              const SizedBox(height: 10),
              _buildNextButton(),
              const SizedBox(height: 30), // Moved button higher
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 200), // Smaller card size
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(15), // Reduced padding inside card
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image with Rounded Borders & Shadows
              Container(
                height: 180, // Smaller image size
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    data["image"]!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                data["title"]!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                data["description"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _introData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 6,
          width: _currentPage == index ? 18 : 6, // Adjusted size
          decoration: BoxDecoration(
            color: _currentPage == index ? const Color.fromARGB(255, 0, 0, 0) : Colors.white70,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: 180, // Smaller button width
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          _currentPage == _introData.length - 1 ? "Get Started" : "Next",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
