import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/services/notification_service.dart';
import 'core/themes/app_theme.dart';
import 'presentation/pages/main_scaffold.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/providers/weather_provider.dart';

// Workmanager hanya diimpor di platform mobile (bukan web)
import 'core/services/background_weather_task.dart'
    if (dart.library.html) 'core/services/background_weather_task_stub.dart';

bool get isMobilePlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('DateFormatting init error: $e');
  }

  // Notifikasi & background task hanya berjalan di Android/iOS
  if (isMobilePlatform) {
    try {
      await NotificationService().init();
      initializeWorkmanager();
    } catch (e) {
      debugPrint('Mobile services init error: $e');
    }
  }

  // Pengaturan tampilan status bar hanya berlaku di mobile
  if (isMobilePlatform) {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
      debugPrint('SystemUI init error: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: MaterialApp(
        title: 'SkyView',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
        home: const _RootPage(),
      ),
    );
  }
}

class _RootPage extends StatefulWidget {
  const _RootPage();

  @override
  State<_RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<_RootPage> {
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    // Preload data sambil splash ditampilkan
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = Provider.of<WeatherProvider>(context, listen: false);
      await p.loadSearchHistory();
      await p.fetchDefaultWeather();
      // Minta izin lokasi background agar notifikasi bisa berjalan saat app ditutup
      // Hanya di platform mobile (Android/iOS)
      if (isMobilePlatform) {
        await p.requestBackgroundLocationPermission();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return SplashPage(onComplete: () {
        if (mounted) setState(() => _splashDone = true);
      });
    }
    return const MainScaffold();
  }
}
