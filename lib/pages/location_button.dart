import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'location_utils.dart';

class LocationButton extends StatefulWidget {
  final TextEditingController controller;
  final Function(Position, String) onLocationCaptured;
  final String? initialGoogleMapsLink;

  const LocationButton({
    Key? key,
    required this.controller,
    required this.onLocationCaptured,
    this.initialGoogleMapsLink,
  }) : super(key: key);

  @override
  State<LocationButton> createState() => _LocationButtonState();
}

class _LocationButtonState extends State<LocationButton> {
  bool _isLoading = false;
  Position? _currentPosition;
  String? _googleMapsLink;

  @override
  void initState() {
    super.initState();
    _googleMapsLink = widget.initialGoogleMapsLink;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final position = await LocationService.getCurrentLocation();

      if (position != null) {
        setState(() {
          _currentPosition = position;
          _googleMapsLink = LocationUtils.generateGoogleMapsLink(
            position.latitude,
            position.longitude,
          );
        });

        final locationText = LocationUtils.formatLocationForDisplay(
          position.latitude,
          position.longitude,
        );

        widget.controller.text = locationText;
        widget.onLocationCaptured(position, _googleMapsLink!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الحصول على الموقع بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'فشل في الحصول على الموقع. تأكد من تفعيل خدمات الموقع والسماح بالوصول.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الحصول على الموقع: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLocationOptions() {
    if (_currentPosition == null) {
      _getCurrentLocation();
      return;
    }

    LocationUtils.showLocationOptionsDialog(context, _currentPosition!, (
      String link,
    ) {
      Clipboard.setData(ClipboardData(text: link));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ رابط الموقع!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _showLocationOptions,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(16),
      ),
      child:
          _isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : const Icon(Icons.my_location),
    );
  }
}
