import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/themes/app_theme.dart';
import 'package:weather_app/presentation/providers/weather_provider.dart';
import 'package:weather_app/presentation/widgets/common.dart';
import 'package:weather_app/presentation/widgets/responsive_layout.dart';
import 'package:weather_app/presentation/widgets/weather_particles.dart';

import '../widgets/home/home_main_cards.dart';
import '../widgets/home/home_forecast.dart';
import '../widgets/home/home_details.dart';
import '../widgets/home/home_search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final p = context.read<WeatherProvider>();
    if (p.weather != null) {
      await p.fetchWeather(p.weather!.cityName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final weather = provider.weather;

        if (provider.isLoading && weather == null) {
          return skyBackground(
            child: const SafeArea(
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: WeatherSkeletonLoader(),
                ),
              ),
            ),
          );
        }

        if (provider.error != null && weather == null) {
          return skyBackground(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: WeatherErrorWidget(
                  message: provider.error!,
                  onRetry: () => provider.fetchWeather('Jakarta'),
                ),
              ),
            ),
          );
        }

        if (weather == null) {
          return skyBackground(
            child: const Center(
              child: Text(
                'Tidak ada data cuaca.',
                style: TextStyle(color: AppColors.textSub),
              ),
            ),
          );
        }

        final particleType = getParticleType(weather.iconCode);

        return Scaffold(
          backgroundColor: AppColors.bg1,
          body: skyBackground(
            colors: _getSkyGradients(weather.iconCode),
            child: Stack(
              children: [
                // 1. Particle Effects layer
                WeatherParticles(type: particleType),

                // 2. Main Scrollable Content
                RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: AppColors.cyan,
                  backgroundColor: AppColors.bg2,
                  child: MaxWidthContainer(
                    child: ListView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 20,
                          bottom: 100),
                      children: [
                        // --- HEADER ---
                        HomeHeader(
                          provider: provider,
                          weather: weather,
                          onSearchTab: () => showSearchDialog(context, provider),
                        ),
                        const SizedBox(height: 24),
                        
                        // --- HERO ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: HomeHeroCard(
                            weather: weather,
                            provider: provider,
                            onRefresh: _handleRefresh,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- MAIN STATS ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: HomeMainStats(weather: weather, provider: provider),
                        ),
                        const SizedBox(height: 20),

                        // --- SUN INFO ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: HomeSunCard(weather: weather),
                        ),
                        const SizedBox(height: 32),

                        // --- HOURLY FORECAST ---
                        HomeHourlyForecast(weather: weather, provider: provider),
                        const SizedBox(height: 32),

                        // --- DAILY FORECAST ---
                        HomeDailyForecast(weather: weather, provider: provider),
                        const SizedBox(height: 32),

                        // --- CHART ---
                        HomeChartSection(weather: weather, provider: provider),
                        const SizedBox(height: 32),

                        // --- EXTRAS ---
                        HomeExtras(weather: weather),
                        const SizedBox(height: 20),

                        // --- WIND COMPASS ---
                        HomeWindCompass(weather: weather, provider: provider),
                        const SizedBox(height: 20),

                        // --- AQI ---
                        const HomeAQI(),
                        const SizedBox(height: 20),

                        // --- TIPS ---
                        HomeTips(weather: weather),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _getSkyGradients(String iconCode) {
    final id = iconCode.length >= 2 ? iconCode.substring(0, 2) : '01';
    final isNight = DateTime.now().hour < 6 || DateTime.now().hour > 19;
    
    switch (id) {
      case '01': return isNight ? AppColors.gradNight : AppColors.gradSunny;
      case '02': 
      case '03':
      case '04': return isNight ? AppColors.gradNight : AppColors.gradCloudy;
      case '09':
      case '10': return AppColors.gradRainy;
      case '11': return AppColors.gradStormy;
      case '13': return AppColors.gradSnowy;
      case '50': return AppColors.gradDawn;
      default: return AppColors.gradSunny;
    }
  }
}
