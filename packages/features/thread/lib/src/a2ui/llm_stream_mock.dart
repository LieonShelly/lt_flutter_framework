class LlmStreamMock {
  static Stream<Map<String, dynamic>> generateAiResponse() async* {
    final nodes = [
      {"id": "root_0", "type": "Column"},

      {
        "id": "node_1",
        "type": "Text",
        "text": "🤖 AI 性能诊断报告：",
        "size": 20.0,
        "parentId": "root_0",
      },

      {"id": "node_2", "type": "Card", "parentId": "root_0"},

      {"id": "node_3", "type": "Column", "parentId": "node_2"},

      {
        "id": "node_4",
        "type": "Text",
        "text": "⏳ 发现主线程 JSON 解析耗时过长...",
        "size": 16.0,
        "parentId": "node_3",
      },
      {
        "id": "node_5",
        "type": "Text",
        "text": "✅ 建议：使用 Isolate.run 剥离计算边界",
        "size": 16.0,
        "parentId": "node_3",
      },

      {"id": "node_6", "type": "Row", "parentId": "root_0"},

      {
        "id": "node_7",
        "type": "Text",
        "text": "👉 [一键应用修复]",
        "size": 18.0,
        "parentId": "node_6",
      },
      {
        "id": "node_8",
        "type": "Text",
        "text": "   [忽略]",
        "size": 16.0,
        "parentId": "node_6",
      },
    ];

    for (var node in nodes) {
      await Future.delayed(const Duration(milliseconds: 600));
      yield node;
    }
  }
}
