import 'package:test/test.dart';
import 'package:algorithm_app/src/sort/count_sort/count_sort.dart';

void main() {
  group('Count Sort Tests', () {
    test('sorts a normal unsorted array', () {
      final arr = [4, 2, 2, 8, 3, 3, 1];
      countSort(arr);
      expect(arr, [1, 2, 2, 3, 3, 4, 8]);
    });

    test('handles already sorted array', () {
      final arr = [1, 2, 3, 4, 5];
      countSort(arr);
      expect(arr, [1, 2, 3, 4, 5]);
    });

    test('handles reverse sorted array', () {
      final arr = [5, 4, 3, 2, 1];
      countSort(arr);
      expect(arr, [1, 2, 3, 4, 5]);
    });

    test('handles array with many duplicates', () {
      final arr = [3, 5, 3, 1, 5, 2, 3, 1];
      countSort(arr);
      expect(arr, [1, 1, 2, 3, 3, 3, 5, 5]);
    });

    test('handles array with all same values', () {
      final arr = [7, 7, 7, 7, 7];
      countSort(arr);
      expect(arr, [7, 7, 7, 7, 7]);
    });

    test('handles single element array', () {
      final arr = [42];
      countSort(arr);
      expect(arr, [42]);
    });

    test('handles two element array', () {
      final arr = [2, 1];
      countSort(arr);
      expect(arr, [1, 2]);
    });

    test('handles empty array', () {
      final arr = <int>[];
      countSort(arr);
      expect(arr, <int>[]);
    });

    test('handles array with negative numbers', () {
      final arr = [3, -1, 4, -5, 2];
      countSort(arr);
      expect(arr, [-5, -1, 2, 3, 4]);
    });

    test('handles array with mixed positive and negative numbers', () {
      final arr = [-3, 5, -1, 0, 2, -4];
      countSort(arr);
      expect(arr, [-4, -3, -1, 0, 2, 5]);
    });

    test('handles array with zero', () {
      final arr = [0, 3, -1, 0, 2];
      countSort(arr);
      expect(arr, [-1, 0, 0, 2, 3]);
    });

    test('handles array with large range', () {
      final arr = [100, 1, 50, 200, 25];
      countSort(arr);
      expect(arr, [1, 25, 50, 100, 200]);
    });

    test('handles array with negative range', () {
      final arr = [-10, -5, -20, -1, -15];
      countSort(arr);
      expect(arr, [-20, -15, -10, -5, -1]);
    });

    test('sorts array with many elements', () {
      final arr = [9, 7, 5, 11, 12, 2, 14, 3, 10, 6];
      countSort(arr);
      expect(arr, [2, 3, 5, 6, 7, 9, 10, 11, 12, 14]);
    });

    test('maintains stability with duplicate values', () {
      final arr = [5, 2, 5, 1, 5, 3];
      countSort(arr);
      expect(arr, [1, 2, 3, 5, 5, 5]);
    });

    test('handles consecutive numbers', () {
      final arr = [5, 3, 4, 2, 1];
      countSort(arr);
      expect(arr, [1, 2, 3, 4, 5]);
    });

    test('handles non-consecutive numbers', () {
      final arr = [10, 30, 20, 50, 40];
      countSort(arr);
      expect(arr, [10, 20, 30, 40, 50]);
    });

    test('handles array with min and max values', () {
      final arr = [5, 1, 9, 1, 9, 5];
      countSort(arr);
      expect(arr, [1, 1, 5, 5, 9, 9]);
    });

    test('maintains array length after sorting', () {
      final arr = [5, 2, 8, 1, 9, 3];
      final originalLength = arr.length;
      countSort(arr);
      expect(arr.length, originalLength);
    });

    test('sorts in place (modifies original array)', () {
      final arr = [3, 1, 2];
      final originalReference = arr;
      countSort(arr);
      expect(identical(arr, originalReference), true);
      expect(arr, [1, 2, 3]);
    });

    test('handles array with small range but large values', () {
      final arr = [1000, 1001, 1002, 1000, 1001];
      countSort(arr);
      expect(arr, [1000, 1000, 1001, 1001, 1002]);
    });

    test('handles array starting from zero', () {
      final arr = [0, 2, 1, 3, 0];
      countSort(arr);
      expect(arr, [0, 0, 1, 2, 3]);
    });

    test('handles array with only negative numbers', () {
      final arr = [-5, -2, -8, -1, -9];
      countSort(arr);
      expect(arr, [-9, -8, -5, -2, -1]);
    });

    test('handles large array with duplicates', () {
      final arr = List.generate(100, (i) => i % 10);
      countSort(arr);
      expect(arr.first, 0);
      expect(arr.last, 9);
      expect(arr.length, 100);
      for (int i = 1; i < arr.length; i++) {
        expect(arr[i] >= arr[i - 1], true);
      }
    });

    test('handles array with single unique value repeated', () {
      final arr = [5, 5, 5, 5, 5, 5];
      countSort(arr);
      expect(arr, [5, 5, 5, 5, 5, 5]);
    });
  });
}
