void main() {

  // Sample data — list of words
  var words = ['apple', 'cat', 'banana', 'dog', 'elephant'];

  // Step 1 — Create a map: key = word, value = its length
  // Using associateWith like the hint says
  var wordLengths = Map.fromIterable(
    words,
    key:   (word) => word,
    value: (word) => (word as String).length,
  );

  // Step 2 — Filter where length > 4 and print
  wordLengths.entries
    .where((entry) => entry.value > 4)
    .forEach((entry) {
      print('${entry.key} has length ${entry.value}');
    });
}