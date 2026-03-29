import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfilePictureState {
  final String? imagePath;
  ProfilePictureState({this.imagePath});
}

class ProfilePictureCubit extends Cubit<ProfilePictureState> {
  ProfilePictureCubit() : super(ProfilePictureState()) {
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    final box = await Hive.openBox('profile_box');
    final savedPath = box.get('profile_image_path');
    if (savedPath != null) {
      emit(ProfilePictureState(imagePath: savedPath));
    }
  }

  Future<void> updateProfilePicture(String newPath) async {
    final box = await Hive.openBox('profile_box');
    await box.put('profile_image_path', newPath);
    emit(ProfilePictureState(imagePath: newPath));
  }
}