
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main.dart';

void main() => runApp(AboutPage());

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.grey,
      appBar: AppBar(
          backgroundColor:Color(0xFF00008B) ,
        title: Center(child: Text("About Us",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                color: Colors.grey,
              padding: const EdgeInsets.all(16.0),
              child: Text('Prachalit Nepal script is a type of abugida script developed from the Nepalese scripts, which are a part of the family of Brahmic scripts descended from Brahmi script. It is used to write Nepal Bhasa, Sanskrit and Pali. Various publications are still published in this script including the Sikkim Herald the bulletin of the Sikkim government (Newari edition)'),

            ),
             Image.network(
              ' https://upload.wikimedia.org/wikipedia/commons/a/a7/Prachalit_consonants.png',
            ),
          ],
        ),

      ),
    );
  }
}
