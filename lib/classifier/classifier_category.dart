class ClassifierCategory {
  final String label;
  final double score;

  ClassifierCategory(this.label, this.score);

  @override
  String toString() {
    return 'PlantCategory{label: $label, score: ${(score * 100).toStringAsFixed(2)}%}';
  }
}