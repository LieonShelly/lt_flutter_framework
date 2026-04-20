// 1. 启动 UI Iframe (作为网络代理)，为兼容 Inspect 模式必须设置可见，但我们可以设得很小
figma.showUI(__html__, { visible: true, width: 300, height: 100 });

// 2. 提取数据发送逻辑
function extractNodeData(node: any): any {
  const nodeData: any = {
    id: node.id,
    name: node.name,
    type: node.type,
  };

  if ('width' in node) nodeData.width = node.width;
  if ('height' in node) nodeData.height = node.height;
  if (node.type === 'TEXT') nodeData.characters = node.characters;
  
  if ('children' in node) {
    nodeData.children = node.children.map((child: any) => extractNodeData(child));
  }

  return nodeData;
}

function pushSelectionData() {
  const selection = figma.currentPage.selection;
  if (selection.length > 0) {
    // 提取所有选中的图层，并递归提取它们的子图层
    const nodesData = selection.map(node => extractNodeData(node));
    figma.ui.postMessage({ type: 'selection-updated', data: nodesData });
  } else {
    figma.ui.postMessage({ type: 'selection-cleared' });
  }
}

// 3. 监听用户在 Figma 中的选择变化
figma.on('selectionchange', pushSelectionData);

// 4. 监听来自 UI 的消息，当 WebSocket 连上时，立刻推送一次初始数据
figma.ui.onmessage = msg => {
  if (msg.type === 'ws-ready') {
    pushSelectionData();
  }
};