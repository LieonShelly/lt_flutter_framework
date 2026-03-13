void insertionSort(List<int> arr) {
  int n = arr.length;

  // 外层循环：从第一个元素开始遍历（默认第0个元素已经是排好序的“手牌”）
  for (int i = 1; i < n; i++) {
    // 把当前需要找位置的元素单独拿出来，记作 key （刚摸到的新牌）
    int key = arr[i];

    // j 代表 左手已经排好序的牌 的最右侧索引
    int j = i - 1;

    // 内层循环：只要前面的牌比Key 大，就把前面的牌往右挪一格
    // j >= 0 防止越界； arr[j] > key 是寻找插入位置的条件
    while (j >= 0 && arr[j] > key) {
      // 把大于 key 的元素往后挪动一位，腾出空间
      arr[j + 1] = arr[j];
      j = j - 1; // 继续向左比较
    }
    // 退出while循环时，说名找到了正确的位置 j + 1
    arr[j + 1] = key;
  }
}
