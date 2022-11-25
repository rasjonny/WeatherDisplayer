import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: (MaterialApp(
        title: 'Home page',
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      )),
    ),
  );
}

enum City { asela, nazret, addis }

typedef WeatherEmoji = String;

const unknownEmoji = "😒";

Future<WeatherEmoji> getWeather(City city) => Future.delayed(
      const Duration(seconds: 1),
      (() => {
            City.asela: '🌧',
            City.nazret: "☀",
            City.addis: "☁",
          }[city]!),
    );

final currentCityProvider = StateProvider<City?>(
  ((ref) => null),
);

final weatherProvider = FutureProvider<WeatherEmoji>(((ref) {
  final city = ref.watch(currentCityProvider);

  if (city != null) {
    return getWeather(city);
  }
  return unknownEmoji;
}));

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(
    BuildContext context,
    ref,
  ) {
    final currentWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
      ),
      body: Column(children: [
        currentWeather.when(
          data: (data) => Text(data),
          error: ((error, stackTrace) => const Text('error')),
          loading: (() => const Padding(
              padding: EdgeInsets.all(8), child: CircularProgressIndicator())),
        ),
        const SizedBox(
          height: 30,
        ),
        Expanded(
          child: ListView.builder(
              itemCount: City.values.length,
              itemBuilder: ((context, index) {
                final city = City.values[index];
                final isSelected = city == ref.watch(currentCityProvider);
                return ListTile(
                    title: Text(city.name),
                    trailing: isSelected ? const Icon(Icons.favorite) : null,
                    onTap: (() =>
                        ref.read(currentCityProvider.notifier).state = city));
              })),
        )
      ]),
    );
  }
}
