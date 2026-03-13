import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _weatherService = WeatherService();
  String _selectedState = 'Durango';
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _weatherService.getWeatherForState(_selectedState);
      setState(() => _weatherData = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _bgColorForDescription(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('lluvia') || d.contains('llovizna')) {
      return const Color(0xFF37474F);
    } else if (d.contains('nube') || d.contains('nublado')) {
      return const Color(0xFF546E7A);
    } else if (d.contains('tormenta')) {
      return const Color(0xFF263238);
    } else if (d.contains('nieve')) {
      return const Color(0xFF78909C);
    } else if (d.contains('niebla') || d.contains('bruma')) {
      return const Color(0xFF607D8B);
    } else {
      // Despejado / soleado
      return const Color(0xFF1565C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _weatherData != null
        ? _bgColorForDescription(_weatherData!.description)
        : const Color(0xFF1565C0);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, bgColor.withOpacity(0.6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Clima',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Selector de estado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedState,
                    dropdownColor: bgColor,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    underline: const SizedBox(),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white),
                    items: _weatherService.availableStates
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedState = val);
                        _fetchWeather();
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Contenido
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _error != null
                        ? _buildError()
                        : _weatherData != null
                            ? _buildWeatherContent()
                            : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white70, size: 64),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (_error!.contains('API Key'))
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Agrega tu API Key en weather_service.dart',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchWeather,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    final w = _weatherData!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          // Ciudad y estado
          Text(
            w.cityName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            w.stateName,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),

          // Icono del clima
          Image.network(
            w.iconUrl,
            width: 100,
            height: 100,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.wb_sunny, color: Colors.white, size: 80),
          ),

          // Temperatura principal
          Text(
            '${w.temperature.round()}°C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.w200,
            ),
          ),

          // Descripción
          Text(
            w.description[0].toUpperCase() + w.description.substring(1),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            'Sensación térmica: ${w.feelsLike.round()}°C',
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 24),

          // Tarjetas de detalles
          Row(
            children: [
              _DetailCard(
                icon: Icons.thermostat_outlined,
                label: 'Mín / Máx',
                value: '${w.tempMin.round()}° / ${w.tempMax.round()}°',
              ),
              const SizedBox(width: 12),
              _DetailCard(
                icon: Icons.water_drop_outlined,
                label: 'Humedad',
                value: '${w.humidity}%',
              ),
              const SizedBox(width: 12),
              _DetailCard(
                icon: Icons.air,
                label: 'Viento',
                value: '${w.windSpeed} m/s',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Botón refrescar
          TextButton.icon(
            onPressed: _fetchWeather,
            icon: const Icon(Icons.refresh, color: Colors.white70),
            label: const Text(
              'Actualizar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
