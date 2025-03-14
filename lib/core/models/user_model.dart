import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';

part 'user_model.g.dart';

@freezed
@JsonSerializable()
 class UserModel with _$UserModel {
  final String id;
  final String mobile;
  final String? name;
  final String? image;
  @JsonKey(name:'privite_key')
  final String? privateKey;
  @JsonKey(name:'public_key')
  final String? publicKey;
   UserModel({
    required this.id,
    required this.mobile,
    required this.name,
    required this.image,
   required this.privateKey,
    required this.publicKey,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
