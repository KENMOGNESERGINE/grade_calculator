
T? maxOf<T extends Comparable<T>>(List<T> list) {
  if (list.isEmpty) return null;

  T max = list[0];
  for (int i = 1; i < list.length; i++) {
    if (list[i].compareTo(max) > 0) {
      max = list[i]; 
    }
  }

  
  return max;
}

void main() {
  print(maxOf([3, 7, 2, 9])); // → 9

  
  print(maxOf(["apple", "banana", "kiwi"])); // → kiwi

  print(maxOf(<int>[])); 
  print(maxOf([1.5, 3.14, 2.71, 0.99])); 
  print(maxOf([42])); 
}