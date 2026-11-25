import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../viewmodels/weather_viewmodel.dart';

/// Halaman pencarian kota dan daftar kota favorit tersimpan.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) {
        context.read<WeatherViewModel>().searchCity(value);
      }
    });
  }

  void _selectLocation(LocationModel location) {
    final viewModel = context.read<WeatherViewModel>();
    viewModel.fetchWeather(location);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cari Lokasi',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: Consumer<WeatherViewModel>(
        builder: (context, viewModel, child) {
          final isQueryEmpty = _searchController.text.trim().isEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: (value) => viewModel.searchCity(value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Ketik nama kota (mis. Yogyakarta)...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.clearSearch();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFD5CCB8),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: isQueryEmpty
                    ? _buildFavoritesSection(context, viewModel)
                    : _buildSearchResultsSection(context, viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Menampilkan daftar kota favorit yang tersimpan di SharedPreferences.
  Widget _buildFavoritesSection(
    BuildContext context,
    WeatherViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final favorites = viewModel.favoriteLocations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
            'Kota Favorit Tersimpan',
            style: GoogleFonts.lora(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: favorites.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border_rounded,
                          size: 48,
                          color: colorScheme.secondary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada kota favorit tersimpan.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Cari nama kota di atas lalu tekan ikon bintang untuk menyimpannya di sini.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: favorites.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final city = favorites[index];
                    return _LocationCard(
                      location: city,
                      isFavorite: true,
                      onTap: () => _selectLocation(city),
                      onToggleFavorite: () => viewModel.toggleFavorite(city),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Menampilkan hasil pencarian dari Open-Meteo Geocoding API.
  Widget _buildSearchResultsSection(
    BuildContext context,
    WeatherViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (viewModel.isSearching) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (viewModel.searchErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 48,
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 12),
              Text(
                viewModel.searchErrorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final results = viewModel.searchResults;
    if (results.isEmpty) {
      return Center(
        child: Text(
          'Ketik nama kota untuk mulai mencari.',
          style: GoogleFonts.plusJakartaSans(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final city = results[index];
        final isFav = viewModel.isFavorite(city);

        return _LocationCard(
          location: city,
          isFavorite: isFav,
          onTap: () => _selectLocation(city),
          onToggleFavorite: () => viewModel.toggleFavorite(city),
        );
      },
    );
  }
}

class _LocationCard extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _LocationCard({
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD5CCB8), width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (location.subtitle.isNotEmpty)
                      Text(
                        location.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip:
                    isFavorite ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFavorite
                      ? colorScheme.secondary
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
