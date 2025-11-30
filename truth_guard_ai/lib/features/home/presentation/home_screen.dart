import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Hindi', 'Marathi'];

  // Example trending false claims
  final List<Map<String, String>> trendingFalseClaims = [
    {
      "title": "Misleading Health Cure",
      "description":
          "A viral post claimed drinking turmeric water cures COVID-19, which is false.",
      "image":
          "https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=800&q=80",
      "category": "Health",
      "verdict": "FALSE",
    },
    {
      "title": "Fake Political Statement",
      "description":
          "A screenshot went viral showing a politician supposedly saying false info.",
      "image":
          "https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=800&q=80",
      "category": "Politics",
      "verdict": "FALSE",
    },
    {
      "title": "False Education Claim",
      "description":
          "A rumor claimed schools are giving free laptops to students, but it’s not verified.",
      "image":
          "https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=800&q=80",
      "category": "Education",
      "verdict": "UNVERIFIED",
    },
    {
      "title": "Fake Vaccine Myth",
      "description":
          "A post claimed vaccines cause infertility, which is scientifically false.",
      "image":
          "https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=800&q=80",
      "category": "Health",
      "verdict": "FALSE",
    },
    {
      "title": "Misleading Weather Alert",
      "description":
          "A viral video showed fake images predicting a cyclone in India, which is incorrect.",
      "image":
          "https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=800&q=80",
      "category": "Weather",
      "verdict": "MISLEADING",
    },
    {
      "title": "Fake Celebrity Statement",
      "description":
          "A viral tweet falsely claimed a celebrity endorsed a product scam.",
      "image":
          "https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=800&q=80",
      "category": "Entertainment",
      "verdict": "FALSE",
    },
    {
      "title": "False Technology News",
      "description":
          "Rumors circulated about a new phone feature being dangerous, which is untrue.",
      "image":
          "https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=800&q=80",
      "category": "Tech",
      "verdict": "FALSE",
    },
    {
      "title": "Misleading Environmental Claim",
      "description":
          "A post suggested planting trees will immediately reduce global warming, which is exaggerated.",
      "image":
          "https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=800&q=80",
      "category": "Environment",
      "verdict": "MISLEADING",
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDCEBFF), Color(0xFFF3F9FF), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // FLOATING CIRCLES
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.14),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent.withOpacity(0.12),
              ),
            ),
          ),

          // LANGUAGE SELECTOR
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  icon: const Icon(Icons.language, color: Colors.blueAccent),
                  items: _languages.map((String lang) {
                    return DropdownMenuItem<String>(
                      value: lang,
                      child: Text(
                        lang,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                    });
                  },
                ),
              ),
            ),
          ),

          // FIXED TOP HEADING
          Positioned(
            top: 40,
            left: 20,
            child: Row(
              children: [
                Text(
                  "TruthGuard AI",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black87, // Fully dark
                  ),
                ),
                SizedBox(width: 8),
                Image.asset('assets/logo.png', height: 32, width: 32),
              ],
            ),
          ),

          // TRENDING FALSE CLAIMS LIST
          Padding(
            padding: const EdgeInsets.only(top: 110, bottom: 160),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: trendingFalseClaims.length,
              itemBuilder: (context, index) {
                final claim = trendingFalseClaims[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      GestureDetector(
                        onTap: () {
                          // Pass the claim data to the detail screen
                          context.go(
                            '/home/claim/1', // Using a dummy ID for now
                            extra: claim,
                          );
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                              ),
                              child: Image.network(
                                claim["image"]!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  claim["verdict"]!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Title + Description
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    claim["category"]!,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              claim["title"]!,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              claim["description"]!,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // FIXED INPUT BOX AT BOTTOM
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.97),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Query Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueGrey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                        hintText: "Paste or type misinformation to verify…",
                        hintStyle: TextStyle(color: Colors.black45),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Analyze Button
                  GestureDetector(
                    onTap: () {
                      final text = _searchController.text.trim();
                      if (text.isNotEmpty) {
                        context.go(
                          Uri(
                            path: '/home/chat',
                            queryParameters: {
                              'q': text,
                              'lang': _selectedLanguage,
                            },
                          ).toString(),
                        );
                        _searchController.clear();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 50,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF003F7D), Color(0xFF005E8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.blueGrey,
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Text(
                        "Analyze Now",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
