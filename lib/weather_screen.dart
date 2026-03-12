import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/addional_info_item.dart' show AdditionalInfoItem;
import 'package:weather_app/hourly_forcast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String selectedCity = 'Kolkata,IN';

  final List<String> cities = [
    'Kolkata,IN',
    'Delhi,IN',
    'Mumbai,IN',
    'Chennai,IN',
    'Bengaluru,IN',
    'Hyderabad,IN',
    'Pune,IN',
    'Ahmedabad,IN',
    'Jaipur,IN',
    'Lucknow,IN',
    'Bhopal,IN',
    'Patna,IN',
    'Chandigarh,IN',
    'Guwahati,IN',
    'Bhubaneswar,IN',
    'Ranchi,IN',
    'Thiruvananthapuram,IN',
    'Visakhapatnam,IN',
    'Nagpur,IN',
    'Surat,IN',
    'London,UK',
    'New York,US',
  ];
  IconData getWeatherIcon(String condition) {
    switch (condition) {
      case 'Clouds':
        return Icons.cloud;
      case 'Rain':
      case 'Drizzle':
        return Icons.grain;
      case 'Thunderstorm':
        return Icons.flash_on;
      case 'Snow':
        return Icons.ac_unit;
      case 'Mist':
      case 'Fog':
      case 'Haze':
        return Icons.blur_on;
      case 'Clear':
      default:
        return Icons.wb_sunny;
    }
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String city = selectedCity;
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=$openWeatherAPIKey&units=metric',
        ),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode != 200) {
        throw data;
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                getCurrentWeather();
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentWeathertemp = currentWeatherData['main']['temp'];
          final currentWeatherCondition =
              currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  decoration: const InputDecoration(
                    labelText: "Select City",
                    border: OutlineInputBorder(),
                  ),
                  items: cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (String? newCity) {
                    setState(() {
                      selectedCity = newCity!;
                    });
                  },
                ),

                const SizedBox(height: 20),
                // main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentWeathertemp °C',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                getWeatherIcon(currentWeatherCondition),
                                size: 64,
                              ),
                              const SizedBox(height: 16),

                              Text(
                                currentWeatherCondition,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Forcast cards
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 1; i <= 6; i++)
                //         HourlyForecastItem(
                //           time: data['list'][i]['dt_txt'].substring(11, 16),
                //           icon:
                //               currentWeatherCondition == 'Clouds' ||
                //                   currentWeatherCondition == 'Rain'
                //               ? Icons.cloud
                //               : Icons.sunny,
                //           temperature: '${data['list'][i]['main']['temp']} k',
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 39,
                    itemBuilder: (context, index) {
                      final item = data['list'][index];
                      final forecastCondition = item['weather'][0]['main'];
                      return HourlyForecastItem(
                        time: item['dt_txt'].substring(11, 16),
                        icon: getWeatherIcon(forecastCondition),
                        temperature: '${item['main']['temp']} °C',
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                // additional info cards
                const Text(
                  'Additonal Information',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '${currentHumidity.toString()} %',
                    ),
                    AdditionalInfoItem(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: '${currentWindSpeed.toString()} m/s',
                    ),
                    AdditionalInfoItem(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: '${currentPressure.toString()} hPa',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
