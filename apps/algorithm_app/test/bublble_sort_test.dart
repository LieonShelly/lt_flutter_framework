import 'package:test/test.dart';

import '../lib/src/sort/bubble_sort/bubble_sort.dart';

void main() {
  group("BublleSort Tests", () {
    test('sorts empty array', () {
      final arr = <int>[];
      bubbleSort(arr);
      expect(arr, equals([]));
    });

    test('sorts single element array', () {
      final arr = [1];
      bubbleSort(arr);
      expect(arr, equals([1]));
    });

    test('sorts already sorted array', () {
      final arr = [1, 2, 3, 4, 5];
      bubbleSort(arr);
      expect(arr, equals([1, 2, 3, 4, 5]));
    });

    test('sorts reverse sorted array', () {
      final arr = [5, 4, 3, 2, 1];
      bubbleSort(arr);
      expect(arr, equals([1, 2, 3, 4, 5]));
    });

    test('sorts random array', () {
      final arr = [10, 7, 8, 9, 1, 5];
      bubbleSort(arr);
      expect(arr, equals([1, 5, 7, 8, 9, 10]));
    });

    test('sorts array with duplicates', () {
      final arr = [3, 1, 4, 1, 5, 9, 2, 6, 5];
      bubbleSort(arr);
      expect(arr, equals([1, 1, 2, 3, 4, 5, 5, 6, 9]));
    });

    test('sorts array with negative numbers', () {
      final arr = [-5, 3, -1, 0, 8, -3];
      bubbleSort(arr);
      expect(arr, equals([-5, -3, -1, 0, 3, 8]));
    });

    test('sorts two elements', () {
      final arr = [2, 1];
      bubbleSort(arr);
      expect(arr, equals([1, 2]));
    });
  });
}
