void mergeSort(List<int> arr, int left, int right) {
  if (left < right) {
    int mid = left + ((right - left) ~/ 2);
    mergeSort(arr, left, mid);
    mergeSort(arr, mid + 1, right);
    merge(arr, left, mid, right);
  }
}

void merge(List<int> arr, int left, int mid, int right) {
  int n1 = mid - left + 1;
  int n2 = right - mid;

  List<int> leftArr = List.filled(n1, 0);
  List<int> rightArr = List.filled(n2, 0);

  for (int i = 0; i < n1; i++) {
    leftArr[i] = arr[left + i];
  }

  for (int j = 0; j < n2; j++) {
    rightArr[j] = arr[mid + 1 + j];
  }

  int i = 0;
  int j = 0;
  int k = left;

  while (i < n1 && j < n2) {
    if (leftArr[i] <= rightArr[j]) {
      arr[k] = leftArr[i];
      i++;
    } else {
      arr[k] = rightArr[j];
      j++;
    }
    k++;
  }

  while (i < n1) {
    arr[k] = leftArr[i];
    i++;
    k++;
  }
  while (j < n2) {
    arr[k] = rightArr[j];
    j++;
    k++;
  }
}
