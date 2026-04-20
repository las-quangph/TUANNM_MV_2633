import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../common/storage/user_profile_storage.dart';
import 'info_user_state.dart';

class InfoUserCubit extends Cubit<InfoUserState> {
  InfoUserCubit({
    ImagePicker? imagePicker,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        super(const InfoUserState());

  final ImagePicker _imagePicker;

  void setPageIndex(int index) {
    emit(state.copyWith(pageIndex: index));
  }

  void selectGender(InfoUserGender gender) {
    emit(state.copyWith(gender: gender));
  }

  void setAge(int age) {
    emit(state.copyWith(age: age));
  }

  void setWeight(int weight) {
    emit(state.copyWith(weight: weight));
  }

  void setHeight(int height) {
    emit(state.copyWith(height: height));
  }

  void setGoal(String goal) {
    emit(state.copyWith(goal: goal));
  }

  void setFullName(String value) {
    emit(state.copyWith(fullName: value));
  }

  void setNickName(String value) {
    emit(state.copyWith(nickName: value));
  }

  Future<void> pickProfileImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    emit(state.copyWith(profileImagePath: image.path));
  }

  Future<void> saveProfile() async {
    emit(state.copyWith(status: InfoUserStatus.saving));

    await UserProfileStorage.save(
      UserProfileData(
        fullName: state.fullName.trim(),
        nickName: state.nickName.trim(),
        gender: state.gender.name,
        age: state.age,
        weight: state.weight,
        height: state.height,
        goal: state.goal,
        avatarPath: state.profileImagePath,
      ),
    );

    emit(state.copyWith(status: InfoUserStatus.saved));
  }
}
