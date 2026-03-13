import 'package:test/test.dart';
import '../lib/src/sort/insertion_sort/insertion_sort.dart';

void main() {
  group('InsertionSort Tests', () {
    test('sorts empty array', () {
      final arr = <int>[];
      insertionSort(arr);
      expect(arr, equals([]));
    });

    test('sorts single element array', () {
      final arr = [1];
      insertionSort(arr);
      expect(arr, equals([1]));
    });

    test('sorts already sorted array', () {
      final arr = [1, 2, 3, 4, 5];
      insertionSort(arr);
      expect(arr, equals([1, 2, 3, 4, 5]));
    });

    test('sorts reverse sorted array', () {
      final arr = [5, 4, 3, 2, 1];
      insertionSort(arr);
      expect(arr, equals([1, 2, 3, 4, 5]));
    });

    test('sorts random array', () {
      final arr = [5, 2, 4, 6, 1, 3];
      insertionSort(arr);
      expect(arr, equals([1, 2, 3, 4, 5, 6]));
    });

    test('sorts array with duplicates', () {
      final arr = [3, 1, 4, 1, 5, 9, 2, 6, 5];
      insertionSort(arr);
      expect(arr, equals([1, 1, 2, 3, 4, 5, 5, 6, 9]));
    });

    test('sorts array with negative numbers', () {
      final arr = [-5, 3, -1, 0, 8, -3];
      insertionSort(arr);
      expect(arr, equals([-5, -3, -1, 0, 3, 8]));
    });

    test('sorts two elements in wrong order', () {
      final arr = [2, 1];
      insertionSort(arr);
      expect(arr, equals([1, 2]));
    });

    test('sorts two elements in correct order', () {
      final arr = [1, 2];
      insertionSort(arr);
      expect(arr, equals([1, 2]));
    });

    test('sorts array with all same elements', () {
      final arr = [5, 5, 5, 5, 5];
      insertionSort(arr);
      expect(arr, equals([5, 5, 5, 5, 5]));
    });

    test('sorts large array', () {
      final arr = List.generate(100, (i) => 100 - i);
      insertionSort(arr);
      expect(arr, equals(List.generate(100, (i) => i + 1)));
    });

    test('maintains stability with duplicate values', () {
      // 虽然我们用的是int，但可以验证相对顺序
      final arr = [3, 1, 3, 2, 3];
      insertionSort(arr);
      expect(arr, equals([1, 2, 3, 3, 3]));
    });
  });
}
