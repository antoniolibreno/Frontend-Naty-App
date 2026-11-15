class QuizAnswer {
  const QuizAnswer({required this.questionId, required this.optionId});

  final String questionId;
  final String optionId;

  Map<String, String> toJson() => {
        'questionId': questionId,
        'optionId': optionId,
      };
}
