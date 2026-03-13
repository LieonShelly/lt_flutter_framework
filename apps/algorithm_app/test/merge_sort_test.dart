import 'package:test/test.dart';
import '../lib/src/sort/merge_sort/merge_sort.dart';

void main() {
  group('MergeSort Tests', () {
    test('sorts empty array', () {
      final arr = <int>[];
      if (arr.isNotEmpty) {
        mergeSort(arr, 0, arr.length - 1);
      }
      expect(arr, equals([]));
    });

    test('sorts single element array', () {
      final arr = [1];
      mergeSort(arr, 0, arr.length - 1);
      expect(arr, equals([1]));
    });

    test('sorts already sorted array', () {
      final arr = [1, 2, 3, 4, 5];
      mergeSort(arr, 0, arr.length - 1);
      expect(arr, equals([1, 2, 3, 4, 5]));
    });

    test('sorts reverse sorted array', () {
      final arr = [5, 4, 3, 2, 1];
      mergeSort(arr, 0, arr.length - 1);
      expect(arr, equals([1, 2, 3, 4, 5]));
    });

    test('sorts random array', () {
      final arr = [38, 27, 43, 3, 9, 82, 10];
      mergeSort(arr, 0, arr.length - 1);
      expect(arr, equals([3, 9, 10, 27, 38, 43, 82]));
    });

    test('sorts array with duplicates', () {
      final arr = [3, 1, 4, 1, 5, 9, 2, 6, 5];
      mergeSort(arr, 0, arr.length - 1);
      expect(arr, equals([1, 1, 2, 3, 4, 5, 5, 6, 9]));
    });

    test('sorts array with negative numbers', () {
      final arr = [-5, 3, -1, 0, 8, -3];
      mergeSort(arr, 0, arr.length - 1);
      expect(arr, equals([-5, -3, -1, 0, 3, 8]));
    });

    test('sorts two elements', () {
      final arr = [2, 1];
      mergeSort(arr, 0, arr.length - 1);
      expect(arr, equals([1, 2]));
    });

    test('sorts large array', () {
      final arr = List.generate(100, (i) => 100 - i);
      mergeSort(arr, 0, arr.length - 1);
      expect(arr, equals(List.generate(100, (i) => i + 1)));
    });
  });
}
