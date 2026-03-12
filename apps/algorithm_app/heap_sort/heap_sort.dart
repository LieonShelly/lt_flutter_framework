import '../core/core.dart';

void heapSort(List<int> arr) {
  int n = arr.length;
  // 阶段1：构建最大堆
  // 从最后一个 “非子节点” 开始，自底向上进行堆化
  // 最后一个非子节点的索引总是 (n ~/ 2) - 1
  for (int i = (n ~/ 2) - 1; i >= 0; i--) {
    heapify(arr, i, 0);
  }

  // 阶段2：一个一个从堆顶取出最大元素，放到数组尾部
  for (int i = n - 1; i > 0; i--) {
    // 将当前堆顶（最大值）交换到数组末尾（位置i）
    swap(arr, 0, i);
    // 交换后，原来的根节点被破坏了，
    // 我们在剩余的堆(堆大小为i)上重新对根节点（索引0）执行堆化，恢复最大堆
    heapify(arr, i, 0);
  }
}

// 堆化
// 目标：让以索引[i] 为根的子树满足最大堆性质
// 前提：建设[i]的左右子树已经是最大堆了，只有[i]本身可能比较大小
// [n] 是当前堆的有效大小
void heapify(List<int> arr, int n, int i) {
  int largest = i; // 初始化最大值的索引为根节点
  int left = 2 * i + 1; // 左孩子索引
  int right = 2 * i + 2; // 右孩子索引

  // 如果左孩子在堆的范围内，且比当前最大值还大，则更新最大值索引
  if (left < n && arr[left] > arr[largest]) {
    largest = left;
  }
  // 如果右孩子在堆的范围内，且比当前最大值还大，则更新最大值索引
  if (right < n && arr[right] > arr[largest]) {
    largest = right;
  }
  // 如果最大值不是原来的根节点i, 说明规则破坏了，需要调整
  if (largest != i) {
    swap(arr, i, largest); // 让较大的孩子上位
    // 交换后，较小的值掉到了 largest 的位置
    // 这可能进一步破坏下方子树的堆性质。因此需要递归地向下继续堆化
    heapify(arr, n, largest);
  }
}
