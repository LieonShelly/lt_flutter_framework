import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class MetalOverlayEditor extends StatefulWidget {
  final String initialIamgeName;
  const MetalOverlayEditor({required this.initialIamgeName, super.key});

  @override
  State<StatefulWidget> createState() => _MetalOverlayEditorState();
}

class _MetalOverlayEditorState extends State<MetalOverlayEditor> {
  MethodChannel? _channel;
  double _red = 1.0;
  double _green = 0.0;
  double _blue = 0.0;
  double _alpha = 1.0;

  @override
  Widget build(BuildContext context) {
    const String viewType = "plugin.metal_overlay_view";
    final Map<String, dynamic> creationParams = {
      'imageName': widget.initialIamgeName,
    };
    return Column(
      children: [
        Expanded(
          child: UiKitView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onPlatformViewCreate,
          ),
        ),

        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                child: Slider(
                  value: _red,
                  thumbColor: Colors.red,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    setState(() {
                      _red = value;
                    });
                    _updateNativeColor();
                  },
                ),
              ),

              Material(
                child: Slider(
                  value: _green,
                  thumbColor: Colors.green,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      _green = value;
                    });
                    _updateNativeColor();
                  },
                ),
              ),

              Material(
                child: Slider(
                  value: _blue,
                  thumbColor: Colors.blue,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _blue = value;
                    });
                    _updateNativeColor();
                  },
                ),
              ),
              _buildBottomView(context),
            ],
          ),
        ),
      ],
    );
  }

  void _onPlatformViewCreate(int id) {
    _channel = MethodChannel('color_overlayer_$id');
  }

  void _updateNativeColor() {
    if (_channel != null) {
      _channel!.invokeMethod('updateColor', [_red, _green, _blue, _alpha]);
    }
  }

  Widget _buildBottomView(BuildContext context) {
    final container = Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xEBEBEBEB),
      ),
      child: SvgAsset(IconName.close, width: 16, height: 16),
    );
    final padding = Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: container,
    );
    return GestureDetector(
      onTap: () {
        context.pop();
      },
      child: padding,
    );
  }
}
