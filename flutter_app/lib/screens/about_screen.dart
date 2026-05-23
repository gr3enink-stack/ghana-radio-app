import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio Station Logo/Icon
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6A229C).withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/logo-512.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.radio,
                        size: 80,
                        color: Color(0xFF6A229C),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Radio Station Name
            Center(
              child: Text(
                'VAS FM Online',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Media VAS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
            ),
            const SizedBox(height: 40),
            
            // About Section
            _buildSection(
              context,
              'Who We Are',
              'VAS FM Online is a premier internet radio station operated by Media VAS. We are dedicated to delivering high-quality audio content to our listeners around the clock.',
            ),
            const SizedBox(height: 24),
            
            // Mission Section
            _buildSection(
              context,
              'Our Mission',
              'At Media VAS, we stand for:\n\n'
              'V - Verify: We ensure all content is verified and reliable\n'
              'A - Authenticity: We deliver authentic, genuine programming\n'
              'S - Specific: We provide targeted, specialized content for our audience',
            ),
            const SizedBox(height: 24),
            
            // What We Offer
            _buildSection(
              context,
              'What We Offer',
              '• 24/7 Internet Radio Streaming\n'
              '• High-Quality Audio Content\n'
              '• Diverse Programming\n'
              '• Accessible Anywhere, Anytime',
            ),
            const SizedBox(height: 40),
            
            const Divider(),
            const SizedBox(height: 24),
            
            // Version Info
            Center(
              child: Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 30),
                  
                  // POWERED BY ARTHIUM LABS LLC
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF371348)
                              : const Color(0xFF6A229C),
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF5A1D87)
                              : const Color(0xFF5A1D87),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6A229C).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'POWERED BY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ARTHIUM LABS LLC',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Legal Links
                  const Divider(),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Legal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6A229C),
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegalButton(
                        context,
                        icon: Icons.shield_outlined,
                        label: 'Privacy Policy',
                        url: 'https://vasfm-online.vercel.app/privacy',
                      ),
                      const SizedBox(width: 16),
                      _buildLegalButton(
                        context,
                        icon: Icons.gavel,
                        label: 'Terms of Service',
                        url: 'https://vasfm-online.vercel.app/terms',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6A229C),
              ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
        ),
      ],
    );
  }

  Widget _buildLegalButton(BuildContext context, {
    required IconData icon,
    required String label,
    required String url,
  }) {
    return OutlinedButton.icon(
      onPressed: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open $label')),
            );
          }
        }
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
