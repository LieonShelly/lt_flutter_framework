// 1. 启动 UI Iframe (作为网络代理)，但保持隐藏状态
figma.showUI(__html__, { visible: false });

// 2. 监听用户在 Figma 中的选择变化
figma.on('selectionchange', () => {
  const selection = figma.currentPage.selection;

  if (selection.length > 0) {
    const node = selection[0]; // 简单起见，先只取选中的第一个图层

    // ⚠️ 重点：Figma 的 Node 对象非常庞大且包含循环引用，不能直接 JSON 序列化。
    // 我们需要手动提取 AI 真正需要的基础数据。
    const nodeData = {
      id: node.id,
      name: node.name,
      type: node.type,
      width: node.width,
      height: node.height,
      // 如果是文本节点，提取文本内容
      characters: node.type === 'TEXT' ? node.characters : undefined,
    };

    // 把提取好的数据发给 ui.html (由它去发 WebSocket)
    figma.ui.postMessage({ type: 'selection-updated', data: nodeData });
  } else {
    // 没有选中任何东西
    figma.ui.postMessage({ type: 'selection-cleared' });
  }
});