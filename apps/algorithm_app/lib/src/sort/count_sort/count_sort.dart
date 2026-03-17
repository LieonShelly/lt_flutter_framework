void countSort(List<int> arr) {
  if (arr.isEmpty) return;

  // 寻找最大值和最小值
  int minVal = arr[0];
  int maxVal = arr[0];

  for (int i = 1; i < arr.length; i++) {
    if (arr[i] < minVal) minVal = arr[i];
    if (arr[i] > maxVal) maxVal = arr[i];
  }

  // 计算数值范围，创建计数数组和输出数组
  int range = maxVal - minVal + 1;
  List<int> count = List.filled(range, 0);
  List<int> output = List.filled(arr.length, 0);

  // 统计频率
  for (int i = 0; i < arr.length; i++) {
    count[arr[i] - minVal]++;
  }

  // 累加频率
  for (int i = 1; i < count.length; i++) {
    count[i] += count[i - 1];
  }

  // 倒序遍历原数组，按号入座
  for (int i = arr.length - 1; i >= 0; i--) {
    int val = arr[i];
    int pos = count[val - minVal] - 1;
    output[pos] = val;
    count[val - minVal]--;
  }

  // 将排好序的数组拷贝回原数组
  for (int i = 0; i < arr.length; i++) {
    arr[i] = output[i];
  }
}
