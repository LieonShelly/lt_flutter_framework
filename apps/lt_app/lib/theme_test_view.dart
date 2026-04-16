import 'package:flutter/material.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class ThemeTestView extends StatelessWidget {
  const ThemeTestView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 从 Provider 中获取动态控制器
    final themeController = LtThemeProvider.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('动态主题系统测试'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Text(
            '色彩库展示',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // 颜色卡片展示
          Row(
            children: [
              Expanded(
                child: _ColorBox(
                  color: theme.colorScheme.primary,
                  label: 'Primary',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ColorBox(
                  color: theme.colorScheme.secondary,
                  label: 'Secondary',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ColorBox(
                  color: theme.colorScheme.surface,
                  label: 'Surface',
                ),
              ),
            ],
          ),

          const Divider(height: 48),

          Text(
            '主题变体 (LtThemeType)',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // 这里使用 Flutter 原生的 ChoiceChip 进行切换
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: LtThemeType.values.map((type) {
              final isSelected = themeController.themeType == type;
              return ChoiceChip(
                label: Text(type.name),
                selected: isSelected,
                selectedColor: theme.colorScheme.primary.withAlpha(50),
                onSelected: (selected) {
                  if (selected) {
                    // 调用由包暴露的方法改变全局主题
                    themeController.changeTheme(type);
                  }
                },
              );
            }).toList(),
          ),

          const Divider(height: 48),

          Text(
            '深浅模式切换 (ThemeMode)',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // 分段按钮：能够切换深色/浅色/系统模式
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('跟随系统'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('浅色模式'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('深色模式'),
                icon: Icon(Icons.dark_mode),
              ),
            ],
            selected: {themeController.themeMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              // 改变模式
              themeController.changeThemeMode(newSelection.first);
            },
          ),

          const SizedBox(height: 48),

          // 典型按钮样式的演示
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Primary 应用按钮', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Secondary 应用按钮', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// 基于传入色值进行渲染卡片的内部组件件
class _ColorBox extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorBox({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    // 动态计算内部文字颜色，防止被背景色遮挡
    final isDarkBackground = color.computeLuminance() < 0.5;
    final textColor = isDarkBackground ? Colors.white : Colors.black;

    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(50), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '#${color.value.toRadixString(16).toUpperCase().substring(2)}',
            style: TextStyle(
              color: textColor.withAlpha(180),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
