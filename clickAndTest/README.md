# 📲 Click and Test App - Real-Time Health Monitoring

Welcome to the **Click and Test** app repository! This Flutter app fetches heart rate and body temperature data from the Blynk IoT cloud in real time, allowing users to monitor their vitals with ease. The data is collected by an ESP8266 device and transmitted to the cloud, from where the app retrieves it for display.

---

## 📑 Table of Contents
- [Features](#features)
- [Blynk API Integration](#blynk-api-integration)
- [Running the App](#running-the-app)
- [App Preview](#app-preview)
- [Feedback and Contributions](#feedback-and-contributions)

---

## ✨ Features
- **Real-Time Data Retrieval**: Integrates seamlessly with the Blynk API to pull up-to-date heart rate and body temperature data.
- **Dynamic Flutter Widgets**: Displays vitals through dynamic and interactive Flutter widgets, providing a user-friendly interface for monitoring health metrics.

---

## 🌐 Blynk API Integration
The app uses the Blynk API to fetch real-time data from the IoT cloud, which stores the heart rate and temperature readings from the ESP8266.

### Example Code for Data Retrieval
```dart
import 'package:http/http.dart' as http;

Future<void> fetchData() async {
  final response = await http.get(Uri.parse('https://blynk-cloud.com/YOUR_TOKEN/get/V1'));
  if (response.statusCode == 200) {
    // Process data
  } else {
    throw Exception('Failed to load data');
  }
}
```

Replace YOUR_TOKEN with your unique Blynk API token to start fetching data.

## 🚀 Running the App

Follow these steps to set up and run the Click and Test app on your device:

1. Clone the Repository:
```git
git clone https://github.com/yourusername/click-and-test.git
cd clickAndTest
```
2. Install Dependencies:
```git
flutter pub get
```
3. Run the App:
```git
flutter run
```
Ensure you have a device or emulator connected and set up for testing the app.

## 📱 App Preview

The app provides a clean, intuitive interface with separate cards for heart rate and body temperature, allowing users to monitor their vitals in real time. Each card dynamically updates to reflect changes in the data, providing a smooth monitoring experience.<br>You can preview the UI of the app from the presentation attached : **[Introduction-to-Remote-Health-Monitoring-System](./Introduction-to-Remote-Health-Monitoring-System.pptx)**.

## 💬 Feedback and Contributions

If you have suggestions, feature requests, or bug reports, please open an issue in the repository. Contributions to the app, including code improvements and documentation enhancements, are always welcome.
