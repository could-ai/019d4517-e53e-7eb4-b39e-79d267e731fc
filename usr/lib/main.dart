import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TikTokExtractorApp());
}

class TikTokExtractorApp extends StatelessWidget {
  const TikTokExtractorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTok Reels Extractor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00F2FE), // TikTok-ish cyan
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ExtractorHomePage(),
      },
    );
  }
}

class ExtractorHomePage extends StatefulWidget {
  const ExtractorHomePage({super.key});

  @override
  State<ExtractorHomePage> createState() => _ExtractorHomePageState();
}

class _ExtractorHomePageState extends State<ExtractorHomePage> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  List<String> _extractedLinks = [];

  void _extractLinks() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a TikTok username')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _extractedLinks = [];
    });

    // Simulating network delay for scraping
    // TODO: Connect to Supabase Edge Function to trigger Apify/Scraper API
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      // Generating mock links for UI demonstration.
      // In production, this will be replaced by the actual scraped URLs.
      final cleanUsername = username.replaceAll('@', '');
      _extractedLinks = List.generate(
        12,
        (index) => 'https://www.tiktok.com/@$cleanUsername/video/72000000000000000${index.toString().padLeft(2, '0')}'
      );
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _copyAll() {
    if (_extractedLinks.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _extractedLinks.join('\n')));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All links copied to clipboard!')),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TikTok Reels Extractor', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Enter a TikTok username to extract all video links in series.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'TikTok Username (e.g., @username)',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                      ),
                      onSubmitted: (_) => _extractLinks(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _extractLinks,
                        icon: _isLoading 
                            ? const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(strokeWidth: 2)
                              )
                            : const Icon(Icons.download),
                        label: Text(_isLoading ? 'Extracting...' : 'Get All Links'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_extractedLinks.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Extracted Links (${_extractedLinks.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _copyAll,
                    icon: const Icon(Icons.copy_all),
                    label: const Text('Copy All'),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _extractedLinks.length,
                  itemBuilder: (context, index) {
                    final link = _extractedLinks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          link,
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () => _copyToClipboard(link),
                          tooltip: 'Copy Link',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else if (!_isLoading) ...[
              const Expanded(
                child: Center(
                  child: Text(
                    'No links extracted yet.\nEnter a username above to begin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
