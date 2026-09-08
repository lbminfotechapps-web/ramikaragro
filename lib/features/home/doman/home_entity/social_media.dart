import 'package:equatable/equatable.dart';

class SocialMedia extends Equatable {
  final String type;
  final String link;

  const SocialMedia({
    required this.type,
    required this.link,
  });

  @override
  List<Object?> get props => [
        type,
        link,
      ];
}