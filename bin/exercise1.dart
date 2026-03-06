List<int> processList(List<int> numbers, bool Function(int) predicate) {
  return numbers.where(predicate).toList();
}

void main() {
  var nums = [1, 2, 3, 4, 5, 6];

  // Lambda passed as argument — returns true if number is even
  var even = processList(nums, (n) => n % 2 == 0);

  print(even); 
}