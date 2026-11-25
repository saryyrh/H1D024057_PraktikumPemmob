import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../utils/weather_helper.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';

/// Halaman utama aplikasi yang menampilkan cuaca terkini, detail metrik, dan prakiraan harian.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<WeatherViewModel>(
      builder: (context, viewModel, child) {
        final location = viewModel.selectedLocation;
        final isFav = viewModel.isFavorite(location);

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            title: _buildLocationTitle(context, viewModel, location),
            actions: [
              IconButton(
                tooltip: isFav ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
                icon: Icon(
                  isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isFav ? colorScheme.primary : colorScheme.onSurface,
                ),
                onPressed: () {
                  viewModel.toggleFavorite(location);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? '${location.name} dihapus dari kota favorit'
                            : '${location.name} disimpan ke kota favorit',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Cari Kota',
                icon: const Icon(Icons.search_rounded),
                onPressed: () {
                  viewModel.clearSearch();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildBody(context, viewModel),
        );
      },
    );
  }

  /// Judul AppBar berupa nama kota aktif yang bisa diklik sebagai dropdown kota favorit.
  Widget _buildLocationTitle(
    BuildContext context,
    WeatherViewModel viewModel,
    LocationModel location,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final favorites = viewModel.favoriteLocations;

    final titleContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                location.name,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lora(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (favorites.isNotEmpty) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: colorScheme.primary,
              ),
            ],
          ],
        ),
        if (location.subtitle.isNotEmpty)
          Text(
            location.subtitle,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
      ],
    );

    if (favorites.isEmpty) {
      return titleContent;
    }

    return PopupMenuButton<LocationModel>(
      tooltip: 'Pilih Kota Favorit',
      color: const Color(0xFFF5F0E6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFD5CCB8), width: 1),
      ),
      onSelected: (selected) {
        if (selected != location) {
          viewModel.fetchWeather(selected);
        }
      },
      itemBuilder: (context) {
        return favorites.map((city) {
          final isCurrent = city == location;
          return PopupMenuItem<LocationModel>(
            value: city,
            child: Row(
              children: [
                Icon(
                  isCurrent ? Icons.check_rounded : Icons.location_on_outlined,
                  size: 18,
                  color: isCurrent
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        city.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (city.subtitle.isNotEmpty)
                        Text(
                          city.subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: titleContent,
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;

    if (viewModel.isLoading && viewModel.currentWeather == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Memuat data cuaca...',
              style: GoogleFonts.plusJakartaSans(
                color: colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.errorMessage != null && viewModel.currentWeather == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Cuaca',
                style: GoogleFonts.lora(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () =>
                    viewModel.fetchWeather(viewModel.selectedLocation),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final weather = viewModel.currentWeather;
    if (weather == null) {
      return Center(
        child: Text(
          'Belum ada data cuaca.',
          style: GoogleFonts.plusJakartaSans(),
        ),
      );
    }

    final todayRainProb = weather.daily.isNotEmpty
        ? weather.daily.first.precipitationProbabilityMax
        : 0;

    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: () => viewModel.fetchWeather(viewModel.selectedLocation),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          if (viewModel.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAE2D3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD5CCB8), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: colorScheme.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      viewModel.errorMessage!,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        viewModel.fetchWeather(viewModel.selectedLocation),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          _buildHeroSection(context, weather.current),
          const SizedBox(height: 20),
          _buildBentoGrid(context, weather.current, todayRainProb),
          const SizedBox(height: 24),
          Text(
            'Prakiraan Harian',
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildDailyForecastList(context, weather.daily),
        ],
      ),
    );
  }

  /// Bagian Hero: suhu utama berukuran besar di kiri dan detail kondisi di kanan.
  Widget _buildHeroSection(BuildContext context, CurrentWeather current) {
    final colorScheme = Theme.of(context).colorScheme;
    final description = WeatherHelper.getWeatherDescription(current.weatherCode);
    final icon = WeatherHelper.getWeatherIcon(current.weatherCode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE2D3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD5CCB8), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${current.temperature.round()}°',
                style: GoogleFonts.lora(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Terasa seperti ${current.apparentTemperature.round()}°',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bento Grid 2x2 untuk kelembapan, kecepatan angin, curah hujan, dan peluang hujan.
  Widget _buildBentoGrid(
    BuildContext context,
    CurrentWeather current,
    int todayRainProb,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _BentoCard(
          icon: Icons.water_drop_outlined,
          label: 'Kelembapan',
          value: '${current.relativeHumidity}%',
        ),
        _BentoCard(
          icon: Icons.air_rounded,
          label: 'Kecepatan Angin',
          value: '${current.windSpeed.toStringAsFixed(1)} km/j',
        ),
        _BentoCard(
          icon: Icons.umbrella_outlined,
          label: 'Curah Hujan',
          value: '${current.precipitation.toStringAsFixed(1)} mm',
        ),
        _BentoCard(
          icon: Icons.grain_rounded,
          label: 'Peluang Hujan Hari Ini',
          value: '$todayRainProb%',
        ),
      ],
    );
  }

  /// Daftar prakiraan cuaca beberapa hari ke depan.
  Widget _buildDailyForecastList(
    BuildContext context,
    List<DailyWeather> dailyList,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD5CCB8), width: 1),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dailyList.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          color: Color(0xFFD5CCB8),
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final item = dailyList[index];
          final dayName = WeatherHelper.formatDayName(item.time, index: index);
          final description =
              WeatherHelper.getWeatherDescription(item.weatherCode);
          final icon = WeatherHelper.getWeatherIcon(item.weatherCode);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight:
                              index == 0 ? FontWeight.w700 : FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(icon, size: 22, color: colorScheme.primary),
                const SizedBox(width: 8),
                SizedBox(
                  width: 54,
                  child: Row(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        size: 13,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${item.precipitationProbabilityMax}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${item.temperatureMin.round()}°',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.temperatureMax.round()}°',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
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
    );
  }
}

class _BentoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BentoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD5CCB8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.secondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
