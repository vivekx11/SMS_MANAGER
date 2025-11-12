import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(SmsSenderApp());
}

class SmsSenderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Sender App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: SmsHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SmsHomePage extends StatefulWidget {
  @override
  State<SmsHomePage> createState() => _SmsHomePageState();
}

class _SmsHomePageState extends State<SmsHomePage> {
  final Telephony telephony = Telephony.instance;

  final TextEditingController myNumberController = TextEditingController();
  final TextEditingController receiverController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  String? savedMyNumber;

  @override
  void initState() {
    super.initState();
    _loadMyNumber();
  }

  Future<void> _loadMyNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedMyNumber = prefs.getString("my_number");
      if (savedMyNumber != null) {
        myNumberController.text = savedMyNumber!;
      }
    });
  }

  Future<void> _saveMyNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("my_number", myNumberController.text);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Your number saved successfully!")));
  }

  Future<void> _sendSMS() async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;

    if (permissionsGranted == true) {
      String target = receiverController.text.trim();
      String msg = messageController.text.trim();

      if (target.isEmpty || msg.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please fill all fields")));
        return;
      }

      try {
        await telephony.sendSms(to: target, message: msg);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Message sent successfully! ✅")));

        messageController.clear();
        receiverController.clear();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to send SMS: $e")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("SMS permission not granted")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SMS Sender"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: myNumberController,
              decoration: InputDecoration(
                labelText: "Your Phone Number",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _saveMyNumber,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            TextField(
              controller: receiverController,
              decoration: InputDecoration(
                labelText: "Recipient Phone Number (+91XXXXXXXXXX)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: "Enter Message",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _sendSMS,
              icon: Icon(Icons.send),
              label: Text("Send Message"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
