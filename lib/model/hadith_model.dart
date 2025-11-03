class Hadith {
  final String arabic;
  final String english;
  final String urdu;
  final String reference;

  Hadith({
    required this.arabic,
    required this.english,
    required this.urdu,
    required this.reference,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      arabic: json['hadithArabic'] ?? '',
      english: json['hadithEnglish'] ?? '',
      urdu: json['hadithUrdu'] ?? '',
      reference: json['bookSlug'] != null && json['hadithNumber'] != null
          ? "${json['bookSlug']} #${json['hadithNumber']}"
          : '',
    );
  }
}
