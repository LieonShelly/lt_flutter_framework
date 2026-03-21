import 'package:flutter/material.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:booking/booking.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              Center(child: CustomBackButton(blur: false)),
              CustomCheckbox(
                value: true,
                onChanged: (value) {
                  print(value!);
                },
              ),
              ErrrorIndicator(title: "title", label: "label", onPressed: () {}),

              HomeButton(),
            ],
          ),
        ),
      ),
    );
  }
}
