import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final purple = const Color(0xFF6A229C);
    final yellow = const Color(0xFFFCDE2B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
            // Header
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: purple,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Effective Date: May 17, 2026',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
            ),
            const SizedBox(height: 24),

            // Company Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: yellow.withValues(alpha: 0.1),
                border: Border.all(color: yellow.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('App Name:', 'VAS FM Online'),
                  _infoRow('Developer:', 'Arthium Labs (on behalf of Media VAS)'),
                  _infoRow('Contact:', 'privacy@mediavas.com'),
                  _infoRow('Website:', 'https://www.mediavas.com'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Highlight
            _buildHighlight(
              context,
              'Summary:',
              'VAS FM Online does not collect, store, or share any personal information. We only collect anonymous usage data to improve our streaming service.',
            ),
            const SizedBox(height: 24),

            // 1. Introduction
            _buildSection(context, '1. Introduction',
                'Media VAS ("we," "our," or "us") operates the VAS FM Online mobile application. This Privacy Policy explains how we handle information when you use our app.'),

            // 2. Information We Collect
            _buildSection(context, '2. Information We Collect', ''),
            _buildSubSection(context, '2.1 Information You Provide',
                'We do not require you to create an account or provide personal information to use VAS FM Online.'),
            _buildSubSection(context, '2.2 Automatically Collected Information',
                'When you use our app, we automatically collect limited, anonymous information:'),
            _buildBulletList(context, [
              'Device Identifier: A randomly generated ID used solely for tracking active listening sessions',
              'Device Type: Whether you\'re using Android or iOS',
              'Listening Activity: When you play or pause the radio stream',
            ]),
            _buildHighlight(
              context,
              'Important:',
              'The device ID is generated locally on your device and cannot be linked to your identity.',
            ),
            const SizedBox(height: 16),
            _buildSubSection(context, '2.3 Information We DO NOT Collect', ''),
            _buildBulletList(context, [
              'Name, email, or contact information',
              'Location or GPS data',
              'Photos, files, or media',
              'Contacts or address book',
              'Personal identifiers (phone number, etc.)',
              'Payment information (app is free)',
            ]),

            // 3. How We Use Information
            _buildSection(context, '3. How We Use Information',
                'The limited information we collect is used solely for:'),
            _buildBulletList(context, [
              'Counting active listeners in real-time',
              'Monitoring app performance and stability',
              'Improving streaming quality and user experience',
              'Diagnosing technical issues',
            ]),

            // 4. Data Sharing
            _buildSection(context, '4. Data Sharing and Disclosure',
                'We do not sell, trade, or rent your information to third parties.'),
            _buildBody(context,
                'We may share anonymous, aggregated statistics (like total listener counts) for business purposes, but this data cannot identify you personally.'),

            // 5. Data Retention
            _buildSection(context, '5. Data Retention',
                'We retain anonymous usage data for a maximum of 90 days. After this period, the data is automatically deleted from our servers.'),

            // 6. Your Rights
            _buildSection(context, '6. Your Rights and Choices',
                'You have the following rights:'),
            _buildBulletList(context, [
              'Opt-Out: Stop all data collection by not using the app',
              'Access: Contact us to inquire about what data we have',
              'Deletion: Request deletion of your anonymous device ID',
              'Uninstall: Remove the app at any time',
            ]),

            // 7. Children's Privacy
            _buildSection(context, '7. Children\'s Privacy',
                'VAS FM Online is suitable for all ages. We do not knowingly collect personal information from children under 13. Our app does not require registration or personal data from any user.'),

            // 8. Data Security
            _buildSection(context, '8. Data Security',
                'We implement appropriate technical and organizational measures to protect the limited data we collect against unauthorized access, alteration, disclosure, or destruction.'),

            // 9. International Data Transfers
            _buildSection(context, '9. International Data Transfers',
                'Your anonymous usage data may be processed on servers located in the United States. By using our app, you consent to this transfer.'),

            // 10. Changes
            _buildSection(context, '10. Changes to This Policy',
                'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page with an updated effective date.'),

            // 11. Contact Us
            _buildSection(context, '11. Contact Us',
                'If you have questions about this Privacy Policy, please contact us:'),
            _buildBulletList(context, [
              'Email: privacy@mediavas.com',
              'Company: Media VAS',
              'Developer: Arthium Labs',
            ]),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 16),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '\u00A9 2026 Media VAS. All rights reserved.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Developed by Arthium Labs',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFCDE2B),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6A229C),
                ),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildBody(context, content),
          ],
        ],
      ),
    );
  }

  Widget _buildSubSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildBody(context, content),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, String content) {
    return Text(
      content,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
    );
  }

  Widget _buildBulletList(BuildContext context, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('\u2022  '),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildHighlight(BuildContext context, String label, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6A229C).withValues(alpha: 0.15),
        border: const Border(
          left: BorderSide(color: Color(0xFFFCDE2B), width: 4),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
