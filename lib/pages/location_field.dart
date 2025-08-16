import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_button.dart';

class LocationField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final Function(Position, String)? onLocationCaptured;
  final bool isRequired;

  const LocationField({
    Key? key,
    this.labelText = 'الموقع',
    this.hintText = 'اضغط على زر الموقع للحصول على موقعك الحالي',
    this.onLocationCaptured,
    this.isRequired = true,
  }) : super(key: key);

  @override
  State<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {
  final TextEditingController _locationController = TextEditingController();
  String? _googleMapsLink;
  Position? _currentPosition;

  void _handleLocationCaptured(Position position, String googleMapsLink) {
    setState(() {
      _currentPosition = position;
      _googleMapsLink = googleMapsLink;
    });

    if (widget.onLocationCaptured != null) {
      widget.onLocationCaptured!(position, googleMapsLink);
    }
  }

  Future<void> _openInGoogleMaps() async {
    if (_googleMapsLink != null) {
      final uri = Uri.parse(_googleMapsLink!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح خرائط جوجل.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _copyGoogleMapsLink() {
    if (_googleMapsLink != null) {
      Clipboard.setData(ClipboardData(text: _googleMapsLink!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ رابط الموقع!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _locationController,
            textAlign: TextAlign.center,
            readOnly: true,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon:
                  _googleMapsLink != null
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.map, color: Colors.blue),
                            onPressed: _openInGoogleMaps,
                            tooltip: 'فتح في خرائط جوجل',
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.purple),
                            onPressed: _copyGoogleMapsLink,
                            tooltip: 'نسخ رابط الموقع',
                          ),
                        ],
                      )
                      : null,
            ),
            validator:
                widget.isRequired
                    ? (value) =>
                        value!.isEmpty ? 'يرجى الحصول على الموقع' : null
                    : null,
            onTap: () {
              // When the field is tapped, trigger the location button
              if (_currentPosition == null) {
                // This will be handled by the LocationButton
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        LocationButton(
          controller: _locationController,
          onLocationCaptured: _handleLocationCaptured,
          initialGoogleMapsLink: _googleMapsLink,
        ),
      ],
    );
  }
}
