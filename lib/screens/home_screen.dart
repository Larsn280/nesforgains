import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/widgets/custom_app_container.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _launchTrello() async {
    final Uri trelloUrl =
        Uri.parse('https://trello.com/b/LOoMkuCs/nesforgains');
    if (!await launchUrl(trelloUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $trelloUrl');
    }
  }

  Future<void> _launchKalkylator() async {
    final Uri kalkylatorUrl =
        Uri.parse('https://strengthlevel.com/one-rep-max-calculator');
    if (!await launchUrl(kalkylatorUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $kalkylatorUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppContainer(
      titleText: 'NESForGains',
      child: Column(
        children: [
          const SizedBox(height: 40.0),
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
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child; // Image is fully loaded.
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                              color:
                                  Colors.white, // Show progress if available.
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
                  const SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButtons.buildElevatedUrlButton(
                          context: context,
                          onPressed: _launchTrello,
                          text: 'Trello'),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                      CustomButtons.buildElevatedUrlButton(
                          context: context,
                          onPressed: _launchKalkylator,
                          text: 'Kalkylator')
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const Text('Välkommen till NESForGains!',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  const Text(
                    '❄️ Vinterträning: För att inte förvandlas till en soffpotatis i köldchock! ⛄\n'
                    'Snön vräker ner, termometern hånskrattar åt dig, och soffan försöker viska söta lögner om att du inte behöver röra dig. '
                    'Men låt oss vara ärliga – om du inte tar dig i kragen nu, kommer vintern att äta dig levande, en lussekatt i taget.\n\n'
                    '💪 Skärp dig och lyft något: Gymmet väntar, och nej, det räcker inte att lyfta fjärrkontrollen. Om du ska överleva halkan och skotta uppfarten utan att bryta ihop, '
                    'behöver du muskler – stora, arga muskler som skrattar åt snöskyffeln.\n'
                    '☃️ Balans, eller något åt det hållet: Ja, du kan dricka varm choklad, men bara om du också lyfter tungt nog för att förbränna den. '
                    'Annars blir du snart en del av vinterlandskapet – som en snögubbe med dubbelhaka.\n'
                    '❄️ Motivation? Tänk på skidsäsongen: Ingen vill vara den som flåsar som en blåsbälg i första backen. '
                    'Rör på dig nu, så slipper du se ut som en säl på hal is när det väl gäller.\n\n'
                    'Så, dra på dig träningskläderna, sluta gnälla och gör jobbet. Vintern är hård, men det ska du också vara – en svettpöl och ett skrikande pass i taget! 🏋️‍♂️❄️',
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
                  'Användarvillkor',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const Text(' | ', style: TextStyle(color: Colors.white70)),
              TextButton(
                onPressed: () {
                  // Navigate to Privacy Policy page
                },
                child: const Text(
                  ' Integritetspolicy',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
