// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  mobile: json['mobile'] as String,
  name: json['name'] as String?,
  image: json['image'] as String?,
  privateKey: json['privite_key'] as String?,
  publicKey: json['public_key'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'mobile': instance.mobile,
  'name': instance.name,
  'image': instance.image,
  'privite_key': instance.privateKey,
  'public_key': instance.publicKey,
};
