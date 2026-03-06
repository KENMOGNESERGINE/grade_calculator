// Data class — Person
class Person {
  final String name;
  final int age;
  Person(this.name, this.age);
}

void main() {

  // Sample data
  var people = [
    Person('Alice',   25),
    Person('Bob',     30),
    Person('Charlie', 35),
    Person('Anna',    22),
    Person('Ben',     28),
  ];

  // Step 1 — Filter people whose name starts with 'A' or 'B'
  var filtered = people
    .where((p) => p.name.startsWith('A') || p.name.startsWith('B'))
    .toList();

  // Step 2 — Extract ages
  var ages = filtered.map((p) => p.age).toList();

  // Step 3 — Calculate average
  double total   = ages.fold(0.0, (sum, age) => sum + age);
  double average = total / ages.length;

  // Step 4 — Print rounded to 1 decimal place
  print('Average age: ${average.toStringAsFixed(1)}');
}
