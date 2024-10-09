import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Погода',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blueGrey[50],
        textTheme: TextTheme(
          headlineMedium: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.blueGrey, fontSize: 18),
        ),
      ),
      home: WeatherTabs(),
    );
  }
}

class WeatherTabs extends StatefulWidget {
  @override
  _WeatherTabsState createState() => _WeatherTabsState();
}

class _WeatherTabsState extends State<WeatherTabs> {
  final List<String> cities = ["Київ", "Львів", "Одеса", "Харків"];
  String selectedCity = "Київ";
  String temperature = "";
  String condition = "";
  String iconUrl = "";
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWeather(selectedCity);
  }

  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=226f6a5f3aebc00ebe52a4ef4b722cdb&units=metric&lang=ua'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = "${data['main']['temp'].round()}°C";  // Округлення температури
        condition = data['weather'][0]['description'];
        iconUrl = "http://openweathermap.org/img/w/${data['weather'][0]['icon']}.png";
        isLoading = false;
      });
    } else {
      setState(() {
        temperature = "Не вдалося отримати погоду";
        condition = "";
        isLoading = false;
      });
    }
  }

  void onSearch() {
    String newCity = searchController.text.trim();
    if (newCity.isNotEmpty) {
      fetchWeather(newCity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Погода в $selectedCity'),
          backgroundColor: Colors.blueAccent,
          bottom: TabBar(
            onTap: (index) {
              selectedCity = cities[index];
              fetchWeather(selectedCity);
            },
            indicatorColor: Colors.white,
            tabs: [
              for (var city in cities) Tab(text: city),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (var city in cities) buildWeatherScreen(city),
          ],
        ),
      ),
    );
  }

  Widget buildWeatherScreen(String city) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: isLoading
                ? CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (iconUrl.isNotEmpty)
                        Image.network(iconUrl, width: 100, height: 100),
                      SizedBox(height: 20),
                      Text(
                        temperature,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 10),
                      Text(
                        condition,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            labelText: "Введіть місто для пошуку",
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onSubmitted: (value) => onSearch(), // Додано для відправлення при натисканні Enter
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}