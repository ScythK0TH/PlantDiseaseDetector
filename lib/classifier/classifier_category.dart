class ClassifierCategory {
  final String label;
  final double score;
  final int pid;

  ClassifierCategory(this.label, this.score, this.pid);

  @override
  String toString() {
    return 'PlantCategory{label: $label, score: ${(score * 100).toStringAsFixed(2)}%}';
  }
}