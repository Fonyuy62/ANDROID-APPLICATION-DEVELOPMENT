T? maxOf<T extends Comparable<T>>(List<T> list) {
  if (list.isEmpty) return null;

  // Using fold
  return list.fold(list[0], (T current, T element) {
    return element.compareTo(current) > 0 ? element : current;
  });
}

void main() {
  print(maxOf([3, 7, 2, 9]));               // 9
  print(maxOf(["apple", "banana", "kiwi"])); // kiwi
  print(maxOf([]));                          // null
}
