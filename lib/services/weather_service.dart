import 'dart:convert';
import 'package:http/http.dart' as http;

// Modelo de datos del clima
class WeatherData {
  final String cityName;
  final String stateName;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final String description;
  final String iconCode;
  final double windSpeed;

  WeatherData({
    required this.cityName,
    required this.stateName,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.description,
    required this.iconCode,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String stateName) {
    return WeatherData(
      cityName: json['name'],
      stateName: stateName,
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'],
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}

// Ciudad representativa de cada estado
const _cities = {
  'Durango': {'city': 'Durango', 'countryCode': 'MX'},
  'Coahuila': {'city': 'Saltillo', 'countryCode': 'MX'},
  'Nuevo León': {'city': 'Monterrey', 'countryCode': 'MX'},
};

class WeatherService {
  static const String _apiKey = '462cff4db9944a729763fb7554b11ca8';
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherData> getWeatherForState(String stateName) async {
    final cityInfo = _cities[stateName];
    if (cityInfo == null) throw Exception('Estado no encontrado');

    final uri = Uri.parse(
      '$_baseUrl?q=${cityInfo['city']},${cityInfo['countryCode']}'
      '&appid=$_apiKey&units=metric&lang=es',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherData.fromJson(data, stateName);
    } else if (response.statusCode == 401) {
      throw Exception('API Key inválida');
    } else {
      throw Exception('Error al obtener el clima (${response.statusCode})');
    }
  }

  List<String> get availableStates => _cities.keys.toList();
}
