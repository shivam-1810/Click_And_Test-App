import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:syncfusion_flutter_gauges/gauges.dart';

Color getLiquidColor(double tempValue) {
  if (tempValue < 96) {
    return Colors.blue;
  } else if (tempValue < 99) {
    return Colors.green;
  } else if (tempValue < 100.4) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}

Widget temperatureCard(BuildContext context,
    {required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
    required Color valueColor}) {
  final bool isLoadingOrError =
      value == 'Loading...' || value.contains('Error');
  final TextStyle valueStyle = isLoadingOrError
      ? const TextStyle(
          fontSize: 24,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        )
      : TextStyle(
          fontSize: 42,
          color: valueColor,
          fontWeight: FontWeight.bold,
        );

  double tempValue = double.tryParse(value) ?? 0.0;
  if (isLoadingOrError) {
    tempValue = 0.0; // Set to 0 if loading or error
  }

  return SizedBox(
    width: double.infinity,
    child: Card(
      shadowColor: Colors.black,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      size: 42,
                      color: iconColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: valueStyle,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 20,
                        color: valueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  width: 220,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 80,
                        maximum: 110,
                        ranges: <GaugeRange>[
                          GaugeRange(
                            startValue: 80,
                            endValue: 110,
                            gradient: const SweepGradient(
                              colors: [
                                Colors.blue,
                                Colors.green,
                                Colors.orange,
                                Colors.red
                              ],
                              stops: [0.0, 0.6, 0.8, 1.0],
                            ),
                            startWidth: 10,
                            endWidth: 10,
                          ),
                        ],
                        pointers: <GaugePointer>[
                          NeedlePointer(
                            value: tempValue,
                            needleEndWidth: 8,
                            needleLength: 0.6,
                            enableAnimation: true,
                            animationType: AnimationType.ease,
                            animationDuration: 1500,
                            needleColor: getLiquidColor(tempValue),
                            knobStyle: KnobStyle(
                              color: Colors.white,
                              borderColor: getLiquidColor(tempValue),
                            ),
                          ),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Text(
                              isLoadingOrError
                                  ? 'Loading...'
                                  : '$tempValue $unit',
                              style: TextStyle(
                                fontSize: isLoadingOrError ? 12 : 15,
                                fontWeight: isLoadingOrError
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontStyle: isLoadingOrError
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                color: isLoadingOrError
                                    ? Colors.grey
                                    : getLiquidColor(tempValue),
                              ),
                            ),
                            angle: 90,
                            positionFactor: 0.55,
                          ),
                        ],
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
  );
}
