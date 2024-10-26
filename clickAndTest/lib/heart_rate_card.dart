import 'package:flutter/material.dart';
import 'dart:ui';

class GradientLiquidCircularProgressIndicator extends StatefulWidget {
  final double value;
  final double maxValue;
  final List<Color> gradientColors;
  final List<double> gradientStops;
  final String centerText;
  final TextStyle centerTextStyle;
  final double borderWidth;
  final Color borderColor;
  final Color backgroundColor;

  const GradientLiquidCircularProgressIndicator({
    super.key,
    required this.value,
    required this.maxValue,
    required this.gradientColors,
    required this.gradientStops,
    required this.centerText,
    required this.centerTextStyle,
    this.borderWidth = 5.0,
    this.borderColor = Colors.grey,
    this.backgroundColor = Colors.black,
  });

  @override
  // ignore: library_private_types_in_public_api
  _GradientLiquidCircularProgressIndicatorState createState() =>
      _GradientLiquidCircularProgressIndicatorState();
}

class _GradientLiquidCircularProgressIndicatorState
    extends State<GradientLiquidCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _previousValue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(
      covariant GradientLiquidCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    const double threshold = 10.0;
    if ((oldWidget.value - widget.value).abs() > threshold) {
      _controller.reset();
      _animation = Tween<double>(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      );
      _controller.forward();
      _previousValue = widget.value;
    } else if (oldWidget.value != widget.value) {
      _animation =
          Tween<double>(begin: _previousValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.linear),
      );
      _previousValue = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isAnimating && _animation.value == 0) {
      _controller.forward();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: GradientLiquidCircularProgressIndicatorPainter(
            value: _animation.value,
            maxValue: widget.maxValue,
            gradientColors: widget.gradientColors,
            gradientStops: widget.gradientStops,
            borderWidth: widget.borderWidth,
            borderColor: widget.borderColor,
            backgroundColor: widget.backgroundColor,
          ),
          child: Center(
            child: Text(
              widget.centerText,
              style: widget.centerTextStyle,
            ),
          ),
        );
      },
    );
  }
}

class GradientLiquidCircularProgressIndicatorPainter extends CustomPainter {
  final double value;
  final double maxValue;
  final List<Color> gradientColors;
  final List<double> gradientStops;
  final double borderWidth;
  final Color borderColor;
  final Color backgroundColor;

  GradientLiquidCircularProgressIndicatorPainter({
    required this.value,
    required this.maxValue,
    required this.gradientColors,
    required this.gradientStops,
    required this.borderWidth,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        stops: gradientStops,
        startAngle: 0.0,
        endAngle: 2.0 * 3.141592653589793,
        transform: const GradientRotation(-3.141592653589793 / 2),
      ).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final progressPaint = Paint()
      ..color = borderColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Background circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        size.width / 2 - borderWidth / 2, backgroundPaint);

    // Gradient circle
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2 - borderWidth / 2),
      -3.141592653589793 / 2,
      2.0 * 3.141592653589793 * (value / maxValue),
      false,
      paint,
    );

    // Border circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        size.width / 2 - borderWidth / 2, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Color getHeartRateColor(double heartRate) {
  if (heartRate < 60) {
    return Colors.blue;
  } else if (heartRate < 100) {
    return Colors.green;
  } else if (heartRate < 140) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}

Widget heartRateCard(BuildContext context,
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

  int heartRate = int.tryParse(value) ?? 0;
  if (isLoadingOrError) {
    heartRate = 0;
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
                const SizedBox(height: 18),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: GradientLiquidCircularProgressIndicator(
                    value: heartRate.toDouble(),
                    maxValue: 200,
                    gradientColors: const [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.red
                    ],
                    gradientStops: const [0.0, 0.3, 0.7, 1.0],
                    centerText: isLoadingOrError ? 'Loading...' : '$heartRate',
                    centerTextStyle: TextStyle(
                      fontSize: isLoadingOrError ? 20 : 32,
                      fontWeight: isLoadingOrError
                          ? FontWeight.normal
                          : FontWeight.bold,
                      fontStyle: isLoadingOrError
                          ? FontStyle.italic
                          : FontStyle.normal,
                      color: isLoadingOrError
                          ? Colors.grey
                          : getHeartRateColor(heartRate.toDouble()),
                    ),
                    borderWidth: 10.0,
                    borderColor: Colors.grey[800]!,
                    backgroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
