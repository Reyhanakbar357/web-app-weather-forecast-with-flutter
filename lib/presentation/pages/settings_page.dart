import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/themes/app_theme.dart';
import 'package:weather_app/core/utils/responsive_utils.dart';
import 'package:weather_app/presentation/providers/weather_provider.dart';
import 'package:weather_app/presentation/widgets/common.dart';
import 'package:weather_app/presentation/widgets/responsive_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _snack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.bg2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return skyBackground(child: SafeArea(child: Consumer<WeatherProvider>(builder: (ctx, p, __) =>
      MaxWidthContainer(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 100), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(colors: [AppColors.cyan, AppColors.purple]).createShader(b),
            child: Text('Pengaturan', style: GoogleFonts.syne(fontSize: RS.fontSize(context, 28), fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ]).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),

        // Profile card
        GlassCard(
          padding: const EdgeInsets.all(20),
          gradient: LinearGradient(colors: [AppColors.cyan.withAlphaSafe(0.10), AppColors.purple.withAlphaSafe(0.07)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderColor: AppColors.cyan.withAlphaSafe(0.22),
          shadows: [BoxShadow(color: AppColors.cyan.withAlphaSafe(0.08), blurRadius: 30)],
          child: Row(children: [
            Container(width: 54, height: 54,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AppColors.cyan, AppColors.purple]),
                boxShadow: [BoxShadow(color: AppColors.cyan.withAlphaSafe(0.3), blurRadius: 14)]),
              child: const Center(child: Text('🌤', style: TextStyle(fontSize: 26)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('SkyView Premium', style: GoogleFonts.syne(fontSize: RS.fontSize(context, 16), fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Versi 2.0.0 · Real-time Weather', style: TextStyle(color: AppColors.textSub, fontSize: RS.fontSize(context, 11))),
            ])),
            NeonBorderCard(color: AppColors.amber, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text('PRO', style: TextStyle(color: AppColors.amber, fontSize: RS.fontSize(context, 11), fontWeight: FontWeight.w800, letterSpacing: .5))),
          ]),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: .05),
        const SizedBox(height: 20),

        // Quick stats
        Row(children: [
          Expanded(child: _StatBox('🏙️', '${p.searchHistory.length}', 'Pencarian', AppColors.cyan)),
          const SizedBox(width: 10),
          Expanded(child: _StatBox('❤️', '${p.favorites.length}', 'Favorit', AppColors.pink)),
          const SizedBox(width: 10),
          Expanded(child: _StatBox('📡', '6', 'Tab Aktif', AppColors.green)),
        ]).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 22),

        const SectionTitle('Preferensi', accentColor: AppColors.cyan),
        const SizedBox(height: 12),
        _Tile(icon: Icons.thermostat_rounded, iconColor: AppColors.orange, title: 'Satuan Suhu',
          subtitle: p.isCelsius ? 'Celsius (°C)' : 'Fahrenheit (°F)', index: 0,
          trailing: _Switch(value: !p.isCelsius, onChanged: (_) => p.toggleUnit(),
            activeColor: AppColors.orange)),
        _Tile(icon: Icons.air_rounded, iconColor: AppColors.pink, title: 'Satuan Kecepatan Angin',
          subtitle: p.windUnitName, index: 1,
          onTap: () => p.cycleWindUnit()),
        _Tile(icon: Icons.language_rounded, iconColor: AppColors.cyan, title: 'Bahasa',
          subtitle: 'Indonesia', index: 2),
        _Tile(icon: Icons.dark_mode_rounded, iconColor: AppColors.purple, title: 'Tema',
          subtitle: 'Gelap · Deep Space', index: 3),
        _Tile(icon: Icons.notifications_active_rounded, iconColor: AppColors.amber, title: 'Notifikasi Cuaca',
          subtitle: p.notifEnabled ? 'Aktif · Peringatan cuaca ekstrem & harian' : 'Nonaktif · Tap untuk mengaktifkan', index: 4,
          trailing: _Switch(value: p.notifEnabled, onChanged: (_) => p.toggleNotification(), activeColor: AppColors.amber)),

        const SizedBox(height: 20),
        const SectionTitle('Data & Privasi', accentColor: AppColors.purple),
        const SizedBox(height: 12),
        _Tile(icon: Icons.history_rounded, iconColor: AppColors.textSub, title: 'Riwayat Pencarian',
          subtitle: '${p.searchHistory.length} kota tersimpan', index: 5,
          trailing: p.searchHistory.isNotEmpty
            ? GestureDetector(onTap: () { p.clearHistory(); _snack(ctx, '🗑  Riwayat dihapus'); },
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.red.withAlphaSafe(0.12), borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.red.withAlphaSafe(0.3))),
                  child: const Text('Hapus', style: TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w600))))
            : null),
        _Tile(icon: Icons.favorite_rounded, iconColor: AppColors.pink, title: 'Kota Favorit',
          subtitle: '${p.favorites.length} kota disimpan', index: 6),
        _Tile(icon: Icons.storage_rounded, iconColor: AppColors.green, title: 'Cache Data',
          subtitle: 'Data cuaca disimpan lokal', index: 7,
          onTap: () => _snack(ctx, '✅ Cache dibersihkan')),

        const SizedBox(height: 20),
        const SectionTitle('Sumber & Info', accentColor: AppColors.amber),
        const SizedBox(height: 12),
        _Tile(icon: Icons.cloud_rounded, iconColor: AppColors.cyan, title: 'Data Cuaca', subtitle: 'OpenWeatherMap API', index: 8),
        _Tile(icon: Icons.map_rounded, iconColor: AppColors.green, title: 'Peta Dunia', subtitle: 'Esri World Dark Canvas', index: 9),
        _Tile(icon: Icons.radar_rounded, iconColor: AppColors.amber, title: 'Radar Cuaca', subtitle: 'Simulasi real-time interaktif', index: 10),
        _Tile(icon: Icons.flutter_dash, iconColor: AppColors.purple, title: 'Dibuat Dengan', subtitle: 'Flutter · Dart · Provider · flutter_map', index: 11),
        _Tile(icon: Icons.star_rounded, iconColor: AppColors.amber, title: 'Nilai Aplikasi',
          subtitle: 'Beri bintang 5 ⭐', index: 12,
          onTap: () => _snack(ctx, '⭐ Terima kasih atas dukungannya!')),

        const SizedBox(height: 28),
        Center(child: Column(children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(colors: [AppColors.cyan, AppColors.purple]).createShader(b),
            child: Text('SkyView', style: GoogleFonts.syne(fontSize: RS.fontSize(context, 22), fontWeight: FontWeight.w800, color: Colors.white))),
          const SizedBox(height: 4),
          Text('v2.0.0 · Real-time weather everywhere', style: TextStyle(color: AppColors.textMuted, fontSize: RS.fontSize(context, 11))),
          const SizedBox(height: 2),
          Text('Made with ❤️ in Flutter', style: TextStyle(color: AppColors.textMuted, fontSize: RS.fontSize(context, 10))),
        ])).animate(delay: 500.ms).fadeIn(),
      ]))))));
  }
}

class _StatBox extends StatelessWidget {
  final String icon, value, label;
  final Color color;
  const _StatBox(this.icon, this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.symmetric(vertical: 14),
    borderColor: color.withAlphaSafe(0.2),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(icon, style: TextStyle(fontSize: RS.fontSize(context, 20))),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontSize: RS.fontSize(context, 18), fontWeight: FontWeight.w800)),
      Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: RS.fontSize(context, 10))),
    ]));
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final Widget? trailing;
  final int index;
  final VoidCallback? onTap;
  const _Tile({required this.icon, required this.iconColor, required this.title, required this.subtitle,
    this.trailing, required this.index, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(width: RS.space(context, 38), height: RS.space(context, 38),
          decoration: BoxDecoration(color: iconColor.withAlphaSafe(0.12), borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: iconColor, size: RS.fontSize(context, 19))),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: Colors.white, fontSize: RS.fontSize(context, 13), fontWeight: FontWeight.w600)),
          Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: RS.fontSize(context, 11))),
        ])),
        trailing ?? (onTap != null
          ? Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: RS.fontSize(context, 18))
          : const SizedBox()),
      ]),
    ),
  ).animate(delay: Duration(milliseconds: index * 45)).fadeIn(duration: 400.ms).slideX(begin: .03);
}

class _Switch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  const _Switch({required this.value, required this.onChanged, this.activeColor = AppColors.cyan});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(duration: const Duration(milliseconds: 250),
      width: 46, height: 26,
      decoration: BoxDecoration(
        color: value ? activeColor.withAlphaSafe(0.2) : Colors.white.withAlphaSafe(0.07),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: value ? activeColor.withAlphaSafe(0.5) : Colors.white.withAlphaSafe(0.12))),
      child: Padding(padding: const EdgeInsets.all(3),
        child: AnimatedAlign(duration: const Duration(milliseconds: 250), curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 20, height: 20,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: value ? activeColor : Colors.white.withAlphaSafe(0.3),
              boxShadow: value ? [BoxShadow(color: activeColor.withAlphaSafe(0.5), blurRadius: 8)] : []))))));
}
