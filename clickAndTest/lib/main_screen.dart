import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:sasta_app/heart_rate_card.dart';
import 'package:sasta_app/secret.dart';
import 'package:sasta_app/temperature_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  bool isExpanded = false;
  String temperature = 'Loading...';
  String tempUnit = '';
  String heartRate = 'Loading...';
  String heartRateUnit = '';
  bool isLoading = false;
  bool notificationShown = false;
  bool? previouslyConnected;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData({bool manualRefresh = false}) async {
    if (manualRefresh) {
      setState(() {
        isLoading = true;
        notificationShown =
            false;
      });
    }

    try {
      final temperatureResponse = await http.get(Uri.parse(
          'https://blr1.blynk.cloud/external/api/get?token=$BLYNK_TOKEN&v0'));
      final heartRateResponse = await http.get(Uri.parse(
          'https://blr1.blynk.cloud/external/api/get?token=$BLYNK_TOKEN&v1'));

      if (temperatureResponse.statusCode == 200 &&
          heartRateResponse.statusCode == 200) {
        final temperatureValue =
            double.tryParse(json.decode(temperatureResponse.body).toString()) ??
                0.0;
        final heartRateValue =
            int.tryParse(json.decode(heartRateResponse.body).toString()) ?? 0;

        setState(() {
          temperature = temperatureValue.toString();
          tempUnit = '°F';
          heartRate = heartRateValue.toString();
          heartRateUnit = 'bpm';
          isLoading = false;
        });
        checkDeviceConnection(temperatureValue, heartRateValue);
        checkForCriticalValues(temperatureValue, heartRateValue);
      } else {
        setState(() {
          temperature = 'Error';
          tempUnit = '';
          heartRate = 'Error';
          heartRateUnit = '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        temperature = 'Error';
        tempUnit = '';
        heartRate = 'Error';
        heartRateUnit = '';
        isLoading = false;
      });
    }
  }

  void checkForCriticalValues(double temperature, int heartRate) {
    String message = '';
    if (temperature > 99) {
      message += 'High body temperature detected: $temperature°F.\n';
    }
    if ((heartRate > 100 || heartRate < 60) && heartRate != 0) {
      message += 'Abnormal heart rate detected: $heartRate bpm.\n';
    }
    if ((temperature > 100.4 || (heartRate > 100 || heartRate < 60)) &&
        (temperature != 0 && heartRate != 0)) {
      message += '\nPlease seek medical attention as soon as possible.';
    }
    if (message.isNotEmpty && !notificationShown) {
      setState(() {
        notificationShown = true;
      });
      showNotification(message);
    }
  }

  void showNotification(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Health Alert',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 8),
              Divider(color: Colors.grey),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {
        notificationShown =
            true;
      });
    });
  }

  void deviceConnectionAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.redAccent),
              SizedBox(width: 12),
              Text(
                'No connection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Make sure that your device is turned on, has an active internet connection and retry..!',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Try Again',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () {
                if (previouslyConnected == true) {
                  Navigator.of(context).pop();
                } else {
                  fetchData(manualRefresh: true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void checkDeviceConnection(double temperature, int heartRate) {
    bool isCurrentlyConnected = (temperature != 0 || heartRate != 0);

    if (previouslyConnected == null) {
      // First-time check
      previouslyConnected = isCurrentlyConnected;
      if (!isCurrentlyConnected) {
        deviceConnectionAlert();
      }
    } else if (previouslyConnected == true && !isCurrentlyConnected) {
      // Device was connected, now disconnected
      deviceConnectionAlert();
      previouslyConnected = false;
    } else if (previouslyConnected == false && isCurrentlyConnected) {
      // Device was disconnected, now connected
      previouslyConnected = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Transform.translate(
          offset: const Offset(11, 2),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/logo1.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        toolbarHeight: 65,
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Health Monitor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color.fromARGB(255, 80, 200, 255),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.refresh,
                  ),
            onPressed: () {
              fetchData(manualRefresh: true);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Visibility(
            visible: !isLoading,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Temperature card
                    temperatureCard(
                      context,
                      icon: Icons.thermostat,
                      iconColor: Colors.lightBlueAccent,
                      title: 'Body Temperature',
                      value: temperature,
                      unit: tempUnit,
                      valueColor: Colors.cyan,
                    ),
                    const SizedBox(height: 20),
                    // Heart Rate card
                    heartRateCard(
                      context,
                      icon: Icons.favorite_rounded,
                      iconColor: Colors.red,
                      title: 'Heart Rate',
                      value: heartRate,
                      unit: heartRateUnit,
                      valueColor: Colors.cyan,
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'We provide you a platform to have a eye on the data regularly so that you can remotely monitor the health status of anyone. Also, it will show up a pop-up when anything gets abnormal.\nWe are working on integrating a notification system along with this so as to notify you about critical conditions even when you close the app..!\nNice seeing you here, thank you!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 171, 229, 255),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10,
                            sigmaY: 10,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(
                                      Icons.update,
                                      color: Colors.green,
                                      size: 35,
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          'Future Enhancements',
                                          style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more),
                                      onPressed: () {
                                        setState(() {
                                          isExpanded = !isExpanded;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                if (isExpanded)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FutureEnhancementItem(
                                          icon: Icons.favorite,
                                          boldText:
                                              'Blood Pressure and ECG Monitoring :',
                                          text:
                                              ' Keep track of your blood pressure levels and ECG with ease. Will be working on making it useful for doctors and medical care purposes.',
                                        ),
                                        FutureEnhancementItem(
                                          icon: Icons.opacity,
                                          boldText: 'Oxygen Level Detection :',
                                          text:
                                              ' Monitor your blood oxygen saturation to ensure optimal health.',
                                        ),
                                        FutureEnhancementItem(
                                          icon: Icons.auto_graph_rounded,
                                          boldText: 'Data Visualization :',
                                          text:
                                              ' Visualize the trend of change in your health conditions regularly in the more pictographic way with the help of graphs.',
                                        ),
                                        FutureEnhancementItem(
                                          icon: Icons.mood,
                                          boldText: 'Health recommendations :',
                                          text:
                                              ' Get personalized health recommendations as per your body conditions ensuring better health.',
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class FutureEnhancementItem extends StatelessWidget {
  final IconData icon;
  final String boldText;
  final String text;

  const FutureEnhancementItem({
    super.key,
    required this.icon,
    required this.boldText,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: boldText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  TextSpan(
                    text: text,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
