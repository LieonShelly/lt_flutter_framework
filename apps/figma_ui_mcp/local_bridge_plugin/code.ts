// 1. 启动 UI Iframe (作为网络代理)，为兼容 Inspect 模式必须设置可见，但我们可以设得很小
figma.showUI(__html__, { visible: true, width: 300, height: 100 });

// 2. 提取数据发送逻辑
// 颜色转换工具
function rgbaToHex(color: any, opacity: number = 1): string {
  const r = Math.round(color.r * 255).toString(16).padStart(2, '0');
  const g = Math.round(color.g * 255).toString(16).padStart(2, '0');
  const b = Math.round(color.b * 255).toString(16).padStart(2, '0');
  const a = opacity < 1 ? Math.round(opacity * 255).toString(16).padStart(2, '0') : '';
  return `#${r}${g}${b}${a}`.toUpperCase();
}

async function extractNodeData(node: any): Promise<any> {
  const nodeData: any = {
    id: node.id,
    name: node.name,
    type: node.type,
  };

  // 1. 基本尺寸与透明度
  if ('width' in node) nodeData.width = node.width;
  if ('height' in node) nodeData.height = node.height;
  if ('opacity' in node) nodeData.opacity = node.opacity;

  // 2. Auto Layout (Flex) 布局属性
  if ('layoutMode' in node && node.layoutMode !== 'NONE') {
    nodeData.layoutMode = node.layoutMode; // HORIZONTAL, VERTICAL
    nodeData.paddingTop = node.paddingTop;
    nodeData.paddingBottom = node.paddingBottom;
    nodeData.paddingLeft = node.paddingLeft;
    nodeData.paddingRight = node.paddingRight;
    nodeData.itemSpacing = node.itemSpacing;
    nodeData.primaryAxisAlignItems = node.primaryAxisAlignItems; // 主轴对齐
    nodeData.counterAxisAlignItems = node.counterAxisAlignItems; // 交叉轴对齐
  }

  // 3. 颜色与背景 (Fills)
  if ('fills' in node && Array.isArray(node.fills)) {
    const solidFills = node.fills.filter((f: any) => f.type === 'SOLID' && f.visible !== false);
    if (solidFills.length > 0) {
      // 提取第一个纯色填充
      nodeData.backgroundColor = rgbaToHex(solidFills[0].color, solidFills[0].opacity);
    }
  }

  // 4. 描边 (Strokes)
  if ('strokes' in node && Array.isArray(node.strokes)) {
    const solidStrokes = node.strokes.filter((s: any) => s.type === 'SOLID' && s.visible !== false);
    if (solidStrokes.length > 0) {
      nodeData.borderColor = rgbaToHex(solidStrokes[0].color, solidStrokes[0].opacity);
      nodeData.borderWidth = node.strokeWeight;
    }
  }

  // 5. 圆角 (Corner Radius)
  if ('cornerRadius' in node && node.cornerRadius !== figma.mixed) {
    nodeData.cornerRadius = node.cornerRadius;
  } else if ('topLeftRadius' in node) {
    // 处理四个角不一样的情况
    nodeData.cornerRadius = {
      tl: node.topLeftRadius,
      tr: node.topRightRadius,
      bl: node.bottomLeftRadius,
      br: node.bottomRightRadius
    };
  }

  // 6. 阴影 (Effects)
  if ('effects' in node && Array.isArray(node.effects)) {
    const shadows = node.effects.filter((e: any) => e.type === 'DROP_SHADOW' && e.visible !== false);
    if (shadows.length > 0) {
      const s = shadows[0];
      nodeData.shadow = {
        color: rgbaToHex(s.color, s.color.a),
        offset: s.offset,
        radius: s.radius,
        spread: s.spread || 0
      };
    }
  }

  // 7. 文本专属属性
  if (node.type === 'TEXT') {
    nodeData.characters = node.characters;
    if (node.fontSize !== figma.mixed) nodeData.fontSize = node.fontSize;
    if (node.fontName !== figma.mixed) {
      nodeData.fontFamily = node.fontName.family;
      nodeData.fontWeight = node.fontName.style;
    }
    if (node.textAlignHorizontal !== figma.mixed) nodeData.textAlign = node.textAlignHorizontal;
  }
  
  // 8. 图标识别与 SVG 导出
  // 如果节点名字包含 icon 或者它本身就是基础矢量图形，我们就尝试将其导出为 SVG 字符串
  const nameLower = node.name.toLowerCase();
  const isIcon = nameLower.includes('icon') || nameLower.includes('ic_') || node.type === 'VECTOR' || node.type === 'BOOLEAN_OPERATION';
  
  if (isIcon && typeof node.exportAsync === 'function') {
    // 只有在节点可见且宽高大于0时才尝试导出，避免 Figma 报错
    if (node.visible !== false && node.width > 0 && node.height > 0) {
      nodeData.isIcon = true;
      try {
        // 获取 SVG 的二进制数据
        const svgBytes = await node.exportAsync({ format: 'SVG' });
        // 转换为字符串 (规避使用大数组时 apply 的栈溢出风险)
        let svgStr = "";
        for (let i = 0; i < svgBytes.length; i++) {
          svgStr += String.fromCharCode(svgBytes[i]);
        }
        nodeData.svg = svgStr;
      } catch (e: any) {
        // 忽略因为没有可见图层导致的预期内报错
        if (e && e.message && typeof e.message === 'string' && e.message.includes('visible layers')) {
          // 静默忽略
        } else {
          console.warn(`导出 SVG 失败 (${node.name}):`, e);
        }
      }
    }
  }

  // 9. 递归子节点
  if ('children' in node) {
    const childrenData = [];
    for (const child of node.children) {
      childrenData.push(await extractNodeData(child)); // 必须使用 await 深入每一层
    }
    nodeData.children = childrenData;
  }

  return nodeData;
}

async function pushSelectionData() {
  const selection = figma.currentPage.selection;
  if (selection.length > 0) {
    try {
      const nodesData = [];
      for (const node of selection) {
        nodesData.push(await extractNodeData(node));
      }
      figma.ui.postMessage({ type: 'selection-updated', data: nodesData });
    } catch(e) {
      console.error("解析节点失败:", e);
    }
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