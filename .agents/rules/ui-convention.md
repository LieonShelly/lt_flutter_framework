---
trigger: always_on
---

# lt_app UI 开发规范 (UI Standard Rules)

## 核心原则
- **禁止硬编码 (No Hardcoding)**：除特殊间距外，颜色和字体必须使用 `AppColors` 和 `AppTextStyle` 中的定义。
- **语义优先 (Semantic First)**：优先使用语义化方法（如 `.body()` 而不是 `.poppinsRegular(fontSize: 14)`）。
- **资产引用 (Asset Reference)**：图标统一使用 `SvgAsset(IconName.xxx)`。

---

## 1. 颜色规范 (Colors)
当在 Figma 中看到以下色值时，必须映射到对应的 `AppColors`：

| Figma Hex | AppColors 常量 | 用途建议 |
| :--- | :--- | :--- |
| `#FFFDF8` | `AppColors.oat` | **全应用主背景色** |
| `#000000` | `AppColors.black` | 纯黑文字、主按钮背景 |
| `#FFFFFF` | `AppColors.white` | 纯白、次要按钮文字 |
| `#323232` | `AppColors.greyDark` | 次要正文、辅助文字 |
| `#6F6F6F` | `AppColors.greyMedium` | 禁用态、提示文案 |
| `#CDCDCD` | `AppColors.greyNeutral` | 分割线、边框 |
| `#EBEBEB` | `AppColors.greyLight` | 浅色背景填充 |

---

## 2. 字体规范 (Typography)
根据 Figma 中的字体族和字号，选择对应的 `AppTextStyle` 语义化构造函数：

### A. 品牌手写体 (The Little Things / FeltTip)
用于标题和具有手写感的装饰文字。
- **24px** → `AppTextStyle.heading()`
- **18px** → `AppTextStyle.title()`
- **14px** → `AppTextStyle.section()`
- **10px** → `AppTextStyle.subSection()`

### B. 无衬线正文 (Poppins)
用于大多数 UI 交互、正文和列表。
- **16px** → `AppTextStyle.subtitle()`
- **14px** → `AppTextStyle.body()`
- **12px** → `AppTextStyle.caption()`

### C. 等宽/代码感 (IBM Plex Mono)
用于日期副标题、注解或数字展示。
- **12px** → `AppTextStyle.annotation()`

---

## 3. 组件使用准则

### 按钮还原
- **Apple 登录类**：背景 `AppColors.black`，文字 `AppTextStyle.poppinsRegular(color: AppColors.white, fontWeight: FontWeight.w600)`。
- **普通边框类**：背景 `AppColors.oat`，边框 `AppColors.greyDark`，文字 `AppTextStyle.body()`。

### 图标引用
必须通过 `IconName` 枚举引用，严禁直接硬编码字符串路径：
```dart
// 正确做法
SvgAsset(IconName.sun, width: 24)

// 错误做法
SvgPicture.asset('assets/icons/sun.svg')
