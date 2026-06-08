/// WMO weather interpretation codes (Open-Meteo `weather_code`) grouped into a
/// small set of conditions with an emoji. The human label is resolved in the
/// presentation layer via i18n (`t.weather.cond_*`).
enum WeatherCondition {
  clear,
  mainlyClear,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  showers,
  thunderstorm,
  unknown,
}

WeatherCondition weatherConditionFromCode(int? code) => switch (code) {
  0 => WeatherCondition.clear,
  1 || 2 => WeatherCondition.mainlyClear,
  3 => WeatherCondition.cloudy,
  45 || 48 => WeatherCondition.fog,
  51 || 53 || 55 || 56 || 57 => WeatherCondition.drizzle,
  61 || 63 || 65 || 66 || 67 => WeatherCondition.rain,
  71 || 73 || 75 || 77 => WeatherCondition.snow,
  80 || 81 || 82 => WeatherCondition.showers,
  85 || 86 => WeatherCondition.snow,
  95 || 96 || 99 => WeatherCondition.thunderstorm,
  _ => WeatherCondition.unknown,
};

String weatherEmoji(WeatherCondition condition) => switch (condition) {
  WeatherCondition.clear => '☀️',
  WeatherCondition.mainlyClear => '🌤️',
  WeatherCondition.cloudy => '☁️',
  WeatherCondition.fog => '🌫️',
  WeatherCondition.drizzle => '🌦️',
  WeatherCondition.rain => '🌧️',
  WeatherCondition.snow => '🌨️',
  WeatherCondition.showers => '🌦️',
  WeatherCondition.thunderstorm => '⛈️',
  WeatherCondition.unknown => '🌡️',
};
