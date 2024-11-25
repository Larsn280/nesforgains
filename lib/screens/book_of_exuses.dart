import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';

class BookOfExuses extends StatefulWidget {
  const BookOfExuses({super.key});

  @override
  State<BookOfExuses> createState() => _BookOfExusesScreenState();
}

class _BookOfExusesScreenState extends State<BookOfExuses> {
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
                const CustomAppbar(title: 'Book of Exuses!'),
                const SizedBox(height: 40.0),
                Card(
                  color: Colors.black54,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(color: Colors.white, width: 1.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20.0),
                        Text(
                          'Bortförklaringarnas 10 Budord',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          'För att misslyckas i Bänkpress',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          '1. Är månen på rätt ställe? Om månen befinner sig på fel plats på himlen kan dess dragningskraft påverka ditt lyft negativt. Precis som månens gravitation lyfter vattnet och sänker det vid ebb, kan den påverka (dra) i stången åt rätt eller fel håll. Detta handlar bara om nåt gram men kan vara avgörande för huruvida ditt lyft lyckas. Liggande i bänkpressen bör du kunna se månen genom fönstret nästan rakt upp (lyftriktningen) för att optimera dina chanser för att lyckas.\n\n'
                          '2. Sommar/vintertid. Har det nyligen slagit om till sommar eller vintertid? Den moderna människan går efter rutiner. Vi vaknar, går till jobbet, lunchar, kommer hem, äter, går och lägger oss oftast på givna tider, och just det... GYMMAR! Kommer gympasset ur fas p.g.a. sommar/vintertid kan detta påverka rutiner och således prestation på gymmet. Undvik att maxa på en månad efter sommar/vintertid för att optimera dina chanser att lyckas.\n\n'
                          '3. Vila och stress. Har du vilat tillräckligt? Har du vilat rätt? Har du verkligen vilat eller har du varit stressad? Stress skapar nedbrytande hormoner vilket är kontraproduktivt för att vara stark. Du bör även sova tillräckligt men inte vara alltför bekväm eller vila för länge så du blir ovan att anstränga dig. Var aktiv, ta det lugnt och sov och ät ordentligt för att optimera dina chanser för att lyckas.\n\n'
                          '4. Mat och timing. Att äta rätt och vid rätt tid är A och O för att lyckas. Kolhydrater fyller på musklernas glykoslager (bränsle) och behöver intas vid rätt tillfälle. Långsamma kolhydrater (ex. Ris) tar längre tid att omsätta medan snabba kolhydrater, DVS. superprocessad mat, omsätts mycket snabbare och kan ätas närmare inpå passet. Sikta på långsammare kolhydrater och större portioner 2-4 timmar innan och något lättare och mer lättsmält närmare inpå för att optimera dina chanser för att lyckas.\n\n'
                          '5. Träning. Har du tränat rätt för att lyckas? Grundträning skall utföras med hög volym (x ton/pass) som en lång muskelbyggande fas. Medan toppning bör vara en mycket kort fas med relativt tunga vikter och få reps. Det är i denna fas du skapar viktvana samt återhämtar nedtränade muskler. Kötta på med grundträningen relativt nära inpå din maxning för att optimera dina chanser för att lyckas.\n\n'
                          '6. Teknik. Har du rätt teknik vid tunga lyft? Att stressa upp sig och göra slarvfel vid maxningar är jättevanligt och kan stjälpa ett lyft som du annars skulle klara. Sitter inte tekniken vid maxning kan det bero på att du är ovan att lyfta tungt. Lägg in ett eller ett par tunga lyft i alla dina träningspass för att hålla uppe viktvanan och tekniken vid maxning. Detta optimerar dina chanser för att lyckas.\n\n'
                          '7. Musiken. Vad spelas det för musik på gymmet? Ingen vettig människa blir taggad av att lyssna på "surströmmingspolkan" när man ska maxa i bänkpress. Tränar du själv kan du ha egen musik i lurarna, annars måste du vänta på rätt låt och hoppas på att inte bli kall innan den kommer.\n\n'
                          '8. Temperaturen. Temperaturen på gymmet kan variera oerhört. På sommaren kan det vara varmt och kvavt och svårt att syresätta kroppen ordentligt, och på vintern kan det vara kallt och svårt att hålla värmen i setvilan. Kylan går att kontra med att ha en tröja att ta på sig mellan setten, värmen på sommaren går inte att göra så mycket åt, se till att dricka mycket vatten och undvik maxning när du känner dig dåsig av värmen.\n\n'
                          '9. Uppvärmningen. Att standardisera din uppvärmning och köra samma uppvärmning varje gång är viktigt. Den kan dock variera beroende på temperatur. Uppvärmningen ska bli successivt tyngre där de första setten mjukar upp kroppen med rörelse och lätt vikt. Mitten setten skapar core-värme på medeltung vikt och slutet på uppvärmningen väcker upp nervsystemet. Du ska vara svettig men inte trött för att optimera dina chanser för att lyckas.\n\n'
                          '10. Passaren. Har du gjort alla föregående steg rätt, och räknat ut i kalkylatorn att du ska kunna göra ditt lyft men misslyckas ändå, så är det alltid passarens fel. Passaren kanske har distraherat dig på nåt vis? Står och flinar och psykar dig? Har passaren tvättat pungen? Håller passaren käften? Tog passaren i stången för tidigt? Ja, orsakerna kan vara väldigt många. Se till att ha en bra passare för att optimera dina chanser för att lyckas.',
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          'Slutord',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          'Gör du allting rätt men misslyckas så är du helt enkelt för svag. Gör du ett eller flera av ovanstående fel så är du helt enkelt för dålig. Du behöver träna mer och hårdare, din mes.',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          'Håll käften och BÄNKA!',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                CustomButtons.buildElevatedFunctionButton(
                    context: context,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    text: 'Home'),
                const SizedBox(height: 8.0)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
