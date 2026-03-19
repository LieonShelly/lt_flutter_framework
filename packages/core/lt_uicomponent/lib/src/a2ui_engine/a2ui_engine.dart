import 'package:flutter/material.dart';

typedef A2UIWidgetBuilder =
    Widget Function(Map<String, dynamic> props, List<Widget> childrenWidgets);

class A2UIEngine {
  final Map<String, Map<String, dynamic>> _nodeRegistry = {};
  final Map<String, List<String>> _childrenAdjacency = {};
  final String rootId = "root_0";

  final Map<String, A2UIWidgetBuilder> _componetCatalog = {
    'Column': (props, children) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
    'Row': (props, children) => Row(children: children),
    'Text': (props, children) => Text(
      props['text'] ?? '',
      style: TextStyle(fontSize: props['size']?.toDouble() ?? 14.0),
    ),
    'Card': (props, children) => Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: children.isNotEmpty ? children.first : const SizedBox.shrink(),
      ),
    ),
  };

  void ingestNodeStream(Map<String, dynamic> rawNode) {
    final String id = rawNode['id'];
    final String? parentId = rawNode['parentId'];
    _nodeRegistry[id] = rawNode;
    if (parentId != null) {
      _childrenAdjacency.putIfAbsent(parentId, () => []).add(id);
    }
  }

  Widget buildTree(String currentNodeId) {
    final nodeData = _nodeRegistry[currentNodeId];
    if (nodeData == null) return const SizedBox.shrink();
    final String type = nodeData['type'];
    final List<String> childrenIds = _childrenAdjacency[currentNodeId] ?? [];
    final List<Widget> childrenWidgets = childrenIds
        .map((childId) => buildTree(childId))
        .toList();
    final builder = _componetCatalog[type];
    if (builder != null) {
      return builder(nodeData, childrenWidgets);
    } else {
      return const SizedBox.shrink();
    }
  }

  void dispose() {
    _nodeRegistry.clear();
    _childrenAdjacency.clear();
  }
}
