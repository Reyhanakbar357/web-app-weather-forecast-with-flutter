import 'package:flutter/material.dart';
import 'package:weather_app/core/themes/app_theme.dart';
import 'package:weather_app/presentation/providers/weather_provider.dart';

void showSearchDialog(BuildContext context, WeatherProvider provider) {
  final TextEditingController ctrl = TextEditingController();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Search',
    pageBuilder: (ctx, a1, a2) {
      return Scaffold(
        backgroundColor: Colors.black.withAlphaSafe(0.8),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: ctrl,
                        style: const TextStyle(color: Colors.white),
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Cari kota...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, color: AppColors.textMuted),
                            onPressed: () => ctrl.clear(),
                          ),
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            provider.fetchWeather(val.trim());
                            Navigator.pop(ctx);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text('Pencarian Populer', style: TextStyle(color: AppColors.textSub, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: ['Jakarta', 'Bandung', 'Surabaya', 'Denpasar', 'London', 'Tokyo']
                      .map((e) => ActionChip(
                            label: Text(e),
                            backgroundColor: Colors.white.withAlphaSafe(0.1),
                            labelStyle: const TextStyle(color: Colors.white),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            onPressed: () {
                              provider.fetchWeather(e);
                              Navigator.pop(ctx);
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, a1, a2, child) {
      return FadeTransition(
        opacity: a1,
        child: child,
      );
    },
  );
}
