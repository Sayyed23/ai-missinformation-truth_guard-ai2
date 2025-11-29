import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Example trending false claims
  final List<Map<String, String>> trendingFalseClaims = [
    {
      "title": "Misleading Health Cure",
      "description":
          "A viral post claimed drinking turmeric water cures COVID-19, which is false.",
      "image": "https://picsum.photos/seed/1/800/400",
    },
    {
      "title": "Fake Political Statement",
      "description":
          "A screenshot went viral showing a politician supposedly saying false info.",
      "image": "https://picsum.photos/seed/2/800/400",
    },
    {
      "title": "False Education Claim",
      "description":
          "A rumor claimed schools are giving free laptops to students, but it’s not verified.",
      "image": "https://picsum.photos/seed/3/800/400",
    },
    {
      "title": "Fake Vaccine Myth",
      "description":
          "A post claimed vaccines cause infertility, which is scientifically false.",
      "image": "https://picsum.photos/seed/4/800/400",
    },
    {
      "title": "Misleading Weather Alert",
      "description":
          "A viral video showed fake images predicting a cyclone in India, which is incorrect.",
      "image": "https://picsum.photos/seed/5/800/400",
    },
    {
      "title": "Fake Celebrity Statement",
      "description":
          "A viral tweet falsely claimed a celebrity endorsed a product scam.",
      "image": "https://picsum.photos/seed/6/800/400",
    },
    {
      "title": "False Technology News",
      "description":
          "Rumors circulated about a new phone feature being dangerous, which is untrue.",
      "image": "https://picsum.photos/seed/7/800/400",
    },
    {
      "title": "Misleading Environmental Claim",
      "description":
          "A post suggested planting trees will immediately reduce global warming, which is exaggerated.",
      "image": "https://picsum.photos/seed/8/800/400",
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

          // FIXED TOP HEADING
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "TruthGuard AI",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.black87, // Fully dark
                  ),
                ),
                Icon(Icons.shield_outlined, size: 28, color: Colors.black87),
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
                      // Title + Description
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            queryParameters: {'q': text},
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
