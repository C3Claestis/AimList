import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 0)
class ProfileModel {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String? imagePath;

  ProfileModel(
      {required this.name, required this.email, this.imagePath});
}
