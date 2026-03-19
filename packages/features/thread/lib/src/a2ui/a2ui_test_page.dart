import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:thread/src/a2ui/llm_stream_mock.dart';

class A2uiTestPage extends StatefulWidget {
  const A2uiTestPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _A2uiTestPageState();
  }
}

class _A2uiTestPageState extends State<A2uiTestPage> {
  late A2UIEngine _a2uiEngine;
  StreamSubscription? _subscription;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _a2uiEngine = A2UIEngine();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _a2uiEngine.dispose();
    super.dispose();
  }

  void _startAIGeneration() {
    _a2uiEngine.dispose();
    setState(() {
      _isGenerating = true;
    });
    _subscription = LlmStreamMock.generateAiResponse().listen(
      (rawNode) {
        _a2uiEngine.ingestNodeStream(rawNode);
        setState(() {});
      },
      onDone: () {
        setState(() {
          _isGenerating = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('A2UI 渐进式渲染测试')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isGenerating ? null : _startAIGeneration,
              child: Text(_isGenerating ? "AI 正在生成界面" : '请求AI诊断'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _a2uiEngine.buildTree(_a2uiEngine.rootId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
