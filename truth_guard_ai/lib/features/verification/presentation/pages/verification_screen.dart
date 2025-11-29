import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truth_guard_ai/core/network/api_service.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final TextEditingController _claimController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _verifyClaim() async {
    if (_claimController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.verifyClaim(_claimController.text);
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Claim Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _claimController,
              decoration: const InputDecoration(
                labelText: 'Enter claim to verify',
                border: OutlineInputBorder(),
                hintText: 'e.g., Chlorine in pools kills coronavirus',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyClaim,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verify Claim'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            if (_result != null) _buildResultView(_result!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(Map<String, dynamic> result) {
    final verdict = result['verdict'] ?? 'UNKNOWN';
    final confidence = result['confidence'] ?? 0.0;
    final explanation = result['explanation']?['public_summary'] ?? '';
    final evidence = result['evidence'] as List<dynamic>? ?? [];

    Color verdictColor;
    switch (verdict) {
      case 'TRUE':
        verdictColor = Colors.green;
        break;
      case 'FALSE':
        verdictColor = Colors.red;
        break;
      case 'MISLEADING':
        verdictColor = Colors.orange;
        break;
      default:
        verdictColor = Colors.grey;
    }

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: verdictColor.withOpacity(0.1),
                border: Border.all(color: verdictColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    verdict,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: verdictColor,
                    ),
                  ),
                  Text('Confidence: ${(confidence * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Explanation:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(explanation),
            const SizedBox(height: 16),
            const Text(
              'Evidence:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ...evidence.map(
              (e) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(e['title'] ?? 'Unknown Source'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e['org'] ?? ''),
                      const SizedBox(height: 4),
                      Text(e['extract'] ?? ''),
                      const SizedBox(height: 4),
                      Text(
                        e['url'] ?? '',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
