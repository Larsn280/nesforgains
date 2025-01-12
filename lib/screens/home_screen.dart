import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String userName;

  @override
  void initState() {
    super.initState();
    userName = AuthProvider.of(context).username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppConstants.appbackgroundimage),
                fit: BoxFit.cover),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const CustomAppbar(title: 'NESForGains!'),
                const SizedBox(
                  height: 12.0,
                ),
                const SizedBox(height: 28.0),
                Card(
                  color: Colors.black54,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(color: Colors.white, width: 1.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Image.network(
                              'https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExOHp5amkwY2x0MWR5cmRvY3F0bzljNjB2MTY2Z3hqM3R0bWQ4ZGI2diZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/pF8sfgvZvDKPm/giphy.webp',
                              key: const ValueKey('animation'),
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child; // Image is fully loaded.
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                    color: Colors
                                        .white, // Show progress if available.
                                  ),
                                );
                              },
                            ),
                            // const Positioned(
                            //   bottom: 10.0,
                            //   child: Text(
                            //     'Benchpress!!!',
                            //     style: TextStyle(
                            //       color: Colors.white,
                            //       fontWeight: FontWeight.bold,
                            //       fontSize: 20.0,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        const Text('Welcome to NESForGains!',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8.0),
                        const Text(
                          '🎅 Träning i juletid: För att kunna lyfta både granen och alla godsaker! 🎄\n'
                          'När snön faller och julens alla smaker lockar, är det lätt att fastna i soffan med en kopp glögg. '
                          'Men vi vet alla att julen handlar om mer än bara julbord och ledighet – det handlar om att hålla igång '
                          'så att du kan njuta av allt det goda utan att känna dig som en julaftons-dekadens!\n\n'
                          '🎁 Kasta in några rejäla pass: Förbered dig på att bära hem alla julklappar utan att behöva be om hjälp – '
                          'en stark kropp gör att du orkar mer än bara att öppna paket.\n'
                          '🍪 Balans är nyckeln: Sätt upp målet att kunna njuta av pepparkakor och glögg utan att behöva ångra dig dagen efter. '
                          'Det handlar inte om att säga nej till allt, utan att hitta en balans som funkar för dig.\n'
                          '🎅 Upptäck nya recept: Fyll på med måltider som får dig att känna dig både stark och nöjd – för ja, du kan äta både gott och nyttigt samtidigt!\n\n'
                          'Så, när julen rullar in, kör på med träning, god mat och ett hälsosamt sinne. För vi vet att det är möjligt att vara både stark och julglad – ett lyft, en tallrik och en dag i taget! 💪🎄',
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Navigate to Terms of Service page
                      },
                      child: const Text(
                        'Terms of Service',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Text(' | ', style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () {
                        // Navigate to Privacy Policy page
                      },
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
