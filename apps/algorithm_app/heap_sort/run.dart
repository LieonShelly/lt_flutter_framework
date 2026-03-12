import 'heap_sort.dart';

void main() {
  List<int> arr = [1, 2, 3, 4, 5, 6];
  List<int> arr0 = [8, 3, 7, 1, 5, 9, 2];
  print("排序前的数组:$arr0");
  // quickSort(arr, 0, arr.length - 1);
  // quickSortWithMedian(arr0, 0, arr0.length - 1);
  heapSort(arr0);
  print("排序后的数组: $arr0");
}
