class ViralClip {
  final String id;
  final Duration startAt;
  final Duration endAt;
  final String title;
  final double confidence;

  const ViralClip({
    required this.id,
    required this.startAt,
    required this.endAt,
    required this.title,
    required this.confidence,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'startAtSec': startAt.inSeconds,
        'endAtSec': endAt.inSeconds,
        'title': title,
        'confidence': confidence,
      };

  factory ViralClip.fromMap(Map<String, dynamic> map) => ViralClip(
        id: map['id'] as String,
        startAt: Duration(seconds: map['startAtSec'] as int),
        endAt: Duration(seconds: map['endAtSec'] as int),
        title: map['title'] as String,
        confidence: (map['confidence'] as num).toDouble(),
      );
}
