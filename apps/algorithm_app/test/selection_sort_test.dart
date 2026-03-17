import 'package:test/test.dart';
import 'package:algorithm_app/src/sort/selecton_sort/selection_sort.dart';

void main() {
  group('Selection Sort Tests', () {
    test('sorts a normal unsorted array', () {
      final arr = [64, 25, 12, 22, 11];
      selectionSort(arr);
      expect(arr, [11, 12, 22, 25, 64]);
    });

    test('handles already sorted array', () {
      final arr = [1, 2, 3, 4, 5];
      selectionSort(arr);
      expect(arr, [1, 2, 3, 4, 5]);
    });

    test('handles reverse sorted array', () {
      final arr = [5, 4, 3, 2, 1];
      selectionSort(arr);
      expect(arr, [1, 2, 3, 4, 5]);
    });

    test('handles array with duplicate values', () {
      final arr = [3, 5, 3, 1, 5, 2];
      selectionSort(arr);
      expect(arr, [1, 2, 3, 3, 5, 5]);
    });

    test('handles array with all same values', () {
      final arr = [7, 7, 7, 7, 7];
      selectionSort(arr);
      expect(arr, [7, 7, 7, 7, 7]);
    });

    test('handles single element array', () {
      final arr = [42];
      selectionSort(arr);
      expect(arr, [42]);
    });

    test('handles two element array', () {
      final arr = [2, 1];
      selectionSort(arr);
      expect(arr, [1, 2]);
    });

    test('handles empty array', () {
      final arr = <int>[];
      selectionSort(arr);
      expect(arr, <int>[]);
    });

    test('handles array with negative numbers', () {
      final arr = [3, -1, 4, -5, 2];
      selectionSort(arr);
      expect(arr, [-5, -1, 2, 3, 4]);
    });

    test('handles array with mixed positive and negative numbers', () {
      final arr = [-3, 5, -1, 0, 2, -4];
      selectionSort(arr);
      expect(arr, [-4, -3, -1, 0, 2, 5]);
    });

    test('handles array with zero', () {
      final arr = [0, 3, -1, 0, 2];
      selectionSort(arr);
      expect(arr, [-1, 0, 0, 2, 3]);
    });

    test('handles large numbers', () {
      final arr = [1000000, 999999, 1000001, 1];
      selectionSort(arr);
      expect(arr, [1, 999999, 1000000, 1000001]);
    });

    test('sorts array with many elements', () {
      final arr = [9, 7, 5, 11, 12, 2, 14, 3, 10, 6];
      selectionSort(arr);
      expect(arr, [2, 3, 5, 6, 7, 9, 10, 11, 12, 14]);
    });

    test('maintains array length after sorting', () {
      final arr = [5, 2, 8, 1, 9];
      final originalLength = arr.length;
      selectionSort(arr);
      expect(arr.length, originalLength);
    });

    test('does not create new array (sorts in place)', () {
      final arr = [3, 1, 2];
      final originalReference = arr;
      selectionSort(arr);
      expect(identical(arr, originalReference), true);
    });
  });
}
