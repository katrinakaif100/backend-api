import 'package:json_annotation/json_annotation.dart';

part 'model_data.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String password;

  User({required this.id, required this.username, required this.password});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
