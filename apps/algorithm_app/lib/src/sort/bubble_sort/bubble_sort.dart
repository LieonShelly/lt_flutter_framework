import '../../core/core.dart';

// 时间复杂度 最优 O(n) 最坏 O(n^2)
// 空间复杂度为 O(1)
void bubbleSort(List<int> arr) {
  int n = arr.length;
  bool swapped = false;
  for (int i = 0; i < n - 1; i++) {
    for (int j = 0; j < n - i - 1; j++) {
      if (arr[j] > arr[j + 1]) {
        swap(arr, j, j + 1);
        swapped = true;
      }
    }
    if (!swapped) {
      break;
    }
  }
}
