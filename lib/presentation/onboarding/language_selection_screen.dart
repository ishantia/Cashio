import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cashio/l10n/generated/app_localizations.dart';

import '../../core/providers.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'fa', 'name': 'فارسی'},
      {'code': 'ar', 'name': 'العربية'},
      {'code': 'tr', 'name': 'Türkçe'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'es', 'name': 'Español'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.languageSelection ?? 'Choose your language'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected =
                      currentLocale == lang['code'] ||
                      (currentLocale == null && lang['code'] == 'en');

                  return ListTile(
                    title: Text(lang['name']!),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(lang['code']!);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Completing onboarding for Phase 1 as per requirements.
                    // Later, we would move to currency selection, etc.
                    ref
                        .read(onboardingCompleteProvider.notifier)
                        .completeOnboarding();
                    context.go('/dashboard');
                  },
                  child: Text(l10n?.continueButton ?? 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
