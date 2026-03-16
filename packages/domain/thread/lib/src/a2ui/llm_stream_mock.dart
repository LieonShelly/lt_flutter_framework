class LlmStreamMock {
  static Stream<Map<String, dynamic>> generateAiResponse() async* {
    final nodes = [
      // 1. 根节点瞬间到达 (没有任何 parentId)
      {"id": "root_0", "type": "Column"},

      // 2. 标题文字到达
      {
        "id": "node_1",
        "type": "Text",
        "text": "🤖 AI 性能诊断报告：",
        "size": 20.0,
        "parentId": "root_0",
      },

      // 3. AI 思考了一下，决定用一个卡片来装具体的诊断信息
      {"id": "node_2", "type": "Card", "parentId": "root_0"},

      // 4. 卡片内部的垂直布局容器
      {"id": "node_3", "type": "Column", "parentId": "node_2"},

      // 5. 具体的诊断条目开始逐条生成！
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

      // 6. 底部操作区容器
      {"id": "node_6", "type": "Row", "parentId": "root_0"},

      // 7. 操作按钮 (我们用 Text 模拟按钮，或者你可以去 Engine 的目录里注册一个 Button)
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
