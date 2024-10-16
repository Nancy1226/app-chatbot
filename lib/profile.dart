import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'home.page.dart';

class profile extends StatelessWidget {
  const profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.deepPurpleAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Image.asset(
                'asset/img/yop.jpeg',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            Text("Universidad Politecnica De Chiapas"),
            Text("221201"),
            Text("Nancy Guadalupe Jimenez Esccobar"),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
              onPressed: () async {
                final web = Uri.parse('https://github.com/Nancy1226/app-chatbot.git');
                if (await canLaunchUrl(web)) {
                  await launchUrl(web, mode: LaunchMode.externalApplication);
                } else {
                  print('Could not launch $web');
                }
              },
              child: Text(
                'Repositorio',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}