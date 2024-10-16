import 'package:flutter/material.dart';
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
            Text("221201"),
            Text("Nancy Guadalupe Jimenez Escobar"),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}