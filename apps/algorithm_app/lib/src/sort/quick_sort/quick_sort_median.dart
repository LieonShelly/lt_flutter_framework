import 'quick_sort.dart';

int partitionWithMedianOfThree(List<int> arr, int low, int high) {
  int mid = low + ((high - low) ~/ 2);
  if (arr[low] > arr[mid]) {
    swap(arr, low, mid);
  }
  if (arr[low] > arr[high]) {
    swap(arr, low, high);
  }
  if (arr[mid] > arr[high]) {
    swap(arr, mid, high);
  }
  swap(arr, mid, high);
  return partition(arr, low, high);
}

void quickSortWithMedian(List<int> arr, int low, int high) {
  if (low < high) {
    int pi = partitionWithMedianOfThree(arr, low, high);
    quickSortWithMedian(arr, low, pi - 1);
    quickSortWithMedian(arr, pi + 1, high);
  }
}
