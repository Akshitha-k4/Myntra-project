import 'dart:convert';
import 'dart:io';

import 'package:cross_file/src/types/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myntra/screens/ProductScreen.dart';
import 'package:http/http.dart' as http;

class Astroformscreen extends StatefulWidget {
  const Astroformscreen({
    Key? key,
    required this.imagePath,
    required this.base64,
  }) : super(key: key);

  final String imagePath;
  final String base64;

  @override
  _AstroformscreenState createState() => _AstroformscreenState();
}

class _AstroformscreenState extends State<Astroformscreen> {
  late var prediction;
  String selectedGender = 'Female';
  String name = '';
  String time = '';
  String location = '';
  String dob = '';
  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation

  Future<void> sendImageToServer(String imagePath, String dob) async {
    try {
      print("hi$imagePath");
      final response = await http.post(
        Uri.parse('http://192.168.0.120:5000/facecolor'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': imagePath, 'dob': dob}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        print('Predicted color: ${jsonResponse['predicted_color']}');
      } else {
        print('Failed to get response from the server: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back when back arrow is pressed
          },
        ),
        title: Text(
          'All About You',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey, // Assigning GlobalKey to Form widget
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.transparent,
                    backgroundImage: FileImage(File(widget.imagePath)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Let's learn what makes you special.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  CustomInputField(
                    label: 'Name',
                    hintText: 'Leah Lynn',
                    icon: Icons.person,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      name = value;
                      return null; // Return null if the input is valid
                    },
                  ),
                  CustomInputField(
                    label: 'Birth Date',
                    hintText: '2003_03_20',
                    icon: Icons.cake,
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      dob = value!;
                      // You can add date validation logic here
                      return null; // Return null if the input is valid
                    },
                  ),
                  CustomInputField(
                    label: 'Birth Time',
                    hintText: '21:33',
                    icon: Icons.access_time,
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      time = value!;
                      // You can add time validation logic here
                      return null; // Return null if the input is valid
                    },
                  ),
                  CustomInputField(
                    label: 'Location',
                    hintText: 'New York, New York, USA',
                    icon: Icons.location_on,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location';
                      }
                      location = value;
                      return null; // Return null if the input is valid
                    },
                  ),
                  CustomDropdownField(
                    label: 'Gender',
                    icon: Icons.transgender,
                    value: selectedGender,
                    items: ['Male', 'Female', 'Other'],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGender = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 32), // Add some spacing before the button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // dialog cannot be dismissed by tapping outside
                          builder: (BuildContext context) {
                            sendImageToServer(widget.base64, dob);
                            return Dialog(
                              backgroundColor: Colors.white,
                              shadowColor: Colors.white,
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Analysing your skin tone and zodiac sign...',
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 16),
                                    CircularProgressIndicator(
                                      color: Colors.pink,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );

                        // Simulate a delay to mimic data loading process
                        Future.delayed(Duration(seconds: 3), () {
                          Navigator.pop(context); // Close the dialog
                          // Show a confirmation dialog or navigate to a new screen with results
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text('Analysis Complete'),
                                content: Text('You are ready to be styled!'),
                                actions: [
                                  TextButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateColor.resolveWith(
                                                (states) => Colors.white)),
                                    onPressed: () async {
                                      Navigator.pop(
                                          context); // Close the dialog
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (_) => ProductsListScreen(
                                              color: "pink",
                                              gender:
                                                  selectedGender))); // Navigate to ProductsListScreen
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    ),
                    child: Text(
                      'ANALYSE',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomInputField extends StatelessWidget {
  CustomInputField({
    required this.label,
    required this.hintText,
    required this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  final String hintText;
  final IconData icon;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          SizedBox(height: 8),
          TextFormField(
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}

class CustomDropdownField extends StatelessWidget {
  CustomDropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final List<String> items;
  final String label;
  final ValueChanged<String?> onChanged;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          SizedBox(height: 8),
          InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
