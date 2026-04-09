import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class ExternalTextureEditor extends StatefulWidget {
  final String imagePath;
  const ExternalTextureEditor({required this.imagePath, super.key});

  @override
  State<StatefulWidget> createState() => _ExternalTextureEditorState();
}

class _ExternalTextureEditorState extends State<ExternalTextureEditor> {
  final MethodChannel _channel = const MethodChannel('metal_texture_channel');
  double _red = 1.0;
  double _green = 0.0;
  double _blue = 0.0;
  double _alpha = 1.0;
  int? _textureId;

  @override
  void initState() {
    super.initState();
    _initTexture();
  }

  Future<void> _initTexture() async {
    final Map<String, dynamic> params = {'imagePath': widget.imagePath};
    final int? id = await _channel.invokeMethod('initializeTexture', params);
    if (mounted) {
      setState(() {
        _textureId = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: _textureId == null
                ? const CircularProgressIndicator()
                : Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Container(
                          width: 200,
                          height: 200,
                          child: Texture(textureId: _textureId!),
                        ),
                      ),
                    ),
                  ),
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

  void _updateNativeColor() {
    _channel.invokeMethod('updateColor', [_red, _green, _blue, _alpha]);
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
