import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/user_model.dart';

part 'auth_response_model.freezed.dart';

part 'auth_response_model.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class AuthResponseModel with _$AuthResponseModel {
  final String token;
  final UserModel user;
  AuthResponseModel({required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
