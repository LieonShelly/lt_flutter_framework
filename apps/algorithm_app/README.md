# Algorithm App

算法实现和练习项目

## 项目结构

```
algorithm_app/
├── core/           # 核心工具函数
├── heap_sort/      # 堆排序
├── sort/           # 其他排序算法
│   ├── merge_sort/ # 归并排序
│   └── quick_sort/ # 快速排序
└── test/           # 单元测试
```

## 运行测试

### 安装依赖
```bash
cd apps/algorithm_app
dart pub get
```

### 运行所有测试
```bash
dart test
```

### 运行特定测试
```bash
dart test test/heap_sort_test.dart
dart test test/merge_sort_test.dart
dart test test/quick_sort_test.dart
```

### 查看测试覆盖率
```bash
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```

## 算法说明

### 堆排序 (Heap Sort)
- 时间复杂度: O(n log n)
- 空间复杂度: O(1)
- 稳定性: 不稳定

### 归并排序 (Merge Sort)
- 时间复杂度: O(n log n)
- 空间复杂度: O(n)
- 稳定性: 稳定

### 快速排序 (Quick Sort)
- 平均时间复杂度: O(n log n)
- 最坏时间复杂度: O(n²)
- 空间复杂度: O(log n) ~ O(n)
- 稳定性: 不稳定
