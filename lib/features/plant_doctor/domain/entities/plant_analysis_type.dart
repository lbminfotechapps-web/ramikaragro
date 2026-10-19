enum PlantAnalysisType {
  growth,
  disease,
  deficiency,
}

extension PlantAnalysisTypeX on PlantAnalysisType {
  String get title {
    switch (this) {
      case PlantAnalysisType.growth:
        return 'Growth';

      case PlantAnalysisType.disease:
        return 'Disease';

      case PlantAnalysisType.deficiency:
        return 'Deficiency';
    }
  }

  String get marathiPrompt {
    switch (this) {
      case PlantAnalysisType.growth:
        return 'Give the name of tree and list of Nutrient only names '
            'for Growth in Marathi details language with table format';

      case PlantAnalysisType.disease:
        return 'Give the name of tree and identify potential disease '
            'only names and treatment for the same only names '
            'in Marathi details language';

      case PlantAnalysisType.deficiency:
        return 'Give the name of tree and identify Nutrient deficiency '
            'only names for Growth in Marathi details language';
    }
  }

  String get englishPrompt {
    switch (this) {
      case PlantAnalysisType.growth:
        return 'Give the name of tree and list of Nutrient only names '
            'for Growth in English';

      case PlantAnalysisType.disease:
        return 'Give the name of tree and identify potential disease '
            'only names and treatment for the same only names in English';

      case PlantAnalysisType.deficiency:
        return 'Give the name of tree and identify Nutrient deficiency '
            'only names for Growth in English';
    }
  }
}