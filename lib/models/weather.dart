class Weather {
  final String location;
  final double temperatureC;
  final double feelsLikeC;
  final int humidity;
  final int pressure;
  final String condition;
  final String description;
  final double windSpeed;
  final int windDirection;
  final int clouds;
  final int timestamp;
  final Map<String, dynamic>? rawData;

  Weather({
    required this.location,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.humidity,
    required this.pressure,
    required this.condition,
    required this.description,
    required this.windSpeed,
    required this.windDirection,
    required this.clouds,
    required this.timestamp,
    this.rawData,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      location: json['location'] as String,
      temperatureC: (json['temperature_c'] as num).toDouble(),
      feelsLikeC: (json['feels_like_c'] as num).toDouble(),
      humidity: json['humidity'] as int,
      pressure: json['pressure'] as int,
      condition: json['condition'] as String,
      description: json['description'] as String,
      windSpeed: (json['wind_speed'] as num).toDouble(),
      windDirection: json['wind_direction'] as int,
      clouds: json['clouds'] as int,
      timestamp: json['timestamp'] as int,
      rawData: json['raw_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'temperature_c': temperatureC,
      'feels_like_c': feelsLikeC,
      'humidity': humidity,
      'pressure': pressure,
      'condition': condition,
      'description': description,
      'wind_speed': windSpeed,
      'wind_direction': windDirection,
      'clouds': clouds,
      'timestamp': timestamp,
      'raw_data': rawData,
    };
  }
}

