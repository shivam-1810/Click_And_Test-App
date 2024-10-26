#define BLYNK_TEMPLATE_ID "TMPL3qsPLnNkA"
#define BLYNK_TEMPLATE_NAME "First ProjectCopy"
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <BlynkSimpleEsp8266.h>
#include <Ticker.h>
#include "secrets.h"

#define ONE_WIRE_BUS 0      // DS18B20 pin (D3)
#define PULSE_SENSOR_PIN A0 // Pulse sensor pin for ESP8266 (analog pin)

LiquidCrystal_I2C lcd(0x27, 16, 2);
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// Replace with your Blynk Auth Token
char auth[] = BLYNK_AUTH_TOKEN;

// Replace with your WiFi credentials
char ssid[] = SSID;
char pass[] = PASSWORD;

volatile int BPM;                   // Beats Per Minute
volatile int Signal;                // Holds the incoming raw data
volatile int IBI = 600;             // Inter-Beat Interval, initially seeded to 600ms
volatile boolean Pulse = false;     // True when a heartbeat is detected

volatile int rate[10];                      // Array to hold last ten IBI values
volatile unsigned long sampleCounter = 0;   // Time in milliseconds
volatile unsigned long lastBeatTime = 0;    // Time of the last beat
volatile int P = 512;                       // Peak value, seeded
volatile int T = 512;                       // Trough value, seeded
volatile int thresh = 512;                  // Threshold value, seeded
volatile int amp = 100;                     // Amplitude of the pulse waveform, seeded
volatile boolean firstBeat = true;          // True if the first beat is detected
volatile boolean secondBeat = false;        // True if the second beat is detected

Ticker timer;

// Moving Average Filter variables
const int FILTER_SIZE = 10;
int signalBuffer[FILTER_SIZE];
int signalSum = 0;
int signalIndex = 0;

// Low-Pass Filter variables
float alpha = 0.75; // Alpha for low-pass filter
float filteredSignal = 512; // Initial value

void pulseSensorISR() {
  // Read the pulse sensor
  int rawSignal = analogRead(PULSE_SENSOR_PIN);

  // Apply moving average filter
  signalSum -= signalBuffer[signalIndex];
  signalBuffer[signalIndex] = rawSignal;
  signalSum += signalBuffer[signalIndex];
  int smoothedSignal = signalSum / FILTER_SIZE;
  signalIndex = (signalIndex + 1) % FILTER_SIZE;

  // Apply low-pass filter
  filteredSignal = alpha * filteredSignal + (1 - alpha) * smoothedSignal;
  Signal = (int)filteredSignal;

  sampleCounter += 2; // Keep track of the time in milliseconds
  int N = sampleCounter - lastBeatTime; // Time since last beat

  // Find the peak and trough of the pulse wave
  if (Signal < thresh && N > (IBI / 5) * 3) {
    if (Signal < T) {
      T = Signal;
    }
  }

  if (Signal > thresh && Signal > P) {
    P = Signal;
  }

  // Look for the heart beat
  if (N > 250) {
    if ((Signal > thresh) && (Pulse == false) && (N > (IBI / 5) * 3)) {
      Pulse = true;
      IBI = sampleCounter - lastBeatTime;
      lastBeatTime = sampleCounter;

      if (secondBeat) {
        secondBeat = false;
        for (int i = 0; i <= 9; i++) {
          rate[i] = IBI;
        }
      }

      if (firstBeat) {
        firstBeat = false;
        secondBeat = true;
        return;
      }

      // Keep a running total of the last 10 IBI values
      word runningTotal = 0;
      for (int i = 0; i <= 8; i++) {
        rate[i] = rate[i + 1];
        runningTotal += rate[i];
      }

      rate[9] = IBI;
      runningTotal += rate[9];
      runningTotal /= 10;
      BPM = 60000 / runningTotal;
    }
  }

  if (Signal < thresh && Pulse == true) {
    Pulse = false;
    amp = P - T;
    thresh = amp / 2 + T;
    P = thresh;
    T = thresh;
  }

  if (N > 2500) {
    thresh = 512;
    P = 512;
    T = 512;
    lastBeatTime = sampleCounter;
    firstBeat = true;
    secondBeat = false;
  }
}

void setup() {
  Serial.begin(115200);
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("Initializing...");

  sensors.begin();
  pinMode(PULSE_SENSOR_PIN, INPUT);

  Blynk.begin(auth, ssid, pass);

  delay(2000); // Allow time to read initialization message
  lcd.clear();

  // Initialize signal buffer for moving average filter
  for (int i = 0; i < FILTER_SIZE; i++) {
    signalBuffer[i] = analogRead(PULSE_SENSOR_PIN);
    signalSum += signalBuffer[i];
  }

  // Timer setup
  timer.attach_ms(2, pulseSensorISR); // Call pulseSensorISR every 2 milliseconds
}

void loop() {
  Blynk.run();

  // Read Temperature
  sensors.requestTemperatures();
  float temperatureC = sensors.getTempCByIndex(0);
  float temperatureF = (temperatureC * 1.8) + 32;

  // Display Temperature on LCD
  lcd.setCursor(0, 0);
  if (temperatureC == DEVICE_DISCONNECTED_C) {
    lcd.print("Temp: Error");
    Serial.println("Error: Could not read temperature data");
  } else {
    lcd.print("Temp: ");
    lcd.print(temperatureF);
    lcd.print(" F");
    Serial.print("Temperature: ");
    Serial.print(temperatureF);
    Serial.println(" F");
    Blynk.virtualWrite(V0, temperatureF); // Send temperature to Blynk
  }

  // Display and send BPM
  lcd.setCursor(0, 1);
  lcd.print("BPM: ");
  if (BPM < 100) {
    lcd.print(" ");
  }
  lcd.print(BPM);
  lcd.print("   "); // Clear any old digits
  Serial.print("BPM: ");
  Serial.println(BPM);
  Blynk.virtualWrite(V1, BPM); // Send BPM to Blynk

  delay(10); // Delay to reduce CPU load
}