/// Upper-cases the first letter for standalone display of lowercase i18n
/// values ("fruit day" → "Fruit day"). Shared by the moon surfaces (sheet,
/// week agenda, task section).
String sentenceCase(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
