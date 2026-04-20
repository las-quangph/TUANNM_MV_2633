import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../common/storage/user_profile_storage.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({
    ImagePicker? imagePicker,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        super(const EditProfileState());

  final ImagePicker _imagePicker;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: EditProfileStatus.loading, clearErrorMessage: true));

    final profile = await UserProfileStorage.load();
    emit(
      state.copyWith(
        status: EditProfileStatus.ready,
        profile: profile,
        fullName: profile.displayName,
        weightInput: '${profile.weight}',
        heightInput: _formatHeight(profile.height),
        clearErrorMessage: true,
      ),
    );
  }

  void setFullName(String value) {
    emit(state.copyWith(fullName: value, clearErrorMessage: true));
  }

  void setWeightInput(String value) {
    emit(state.copyWith(weightInput: value, clearErrorMessage: true));
  }

  void setHeightInput(String value) {
    emit(state.copyWith(heightInput: value, clearErrorMessage: true));
  }

  Future<void> pickAvatar() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    emit(
      state.copyWith(
        profile: state.profile.copyWith(avatarPath: image.path),
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> saveProfile() async {
    final fullName = state.fullName.trim();
    final weight = _parseWeight(state.weightInput);
    final height = _parseHeight(state.heightInput);

    if (fullName.isEmpty || weight == null || height == null) {
      emit(
        state.copyWith(
          status: EditProfileStatus.failure,
          errorMessage: 'Please enter valid full name, weight, and height.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: EditProfileStatus.saving, clearErrorMessage: true));

    final updatedProfile = state.profile.copyWith(
      fullName: fullName,
      nickName: fullName,
      weight: weight,
      height: height,
    );

    await UserProfileStorage.save(updatedProfile);

    emit(
      state.copyWith(
        status: EditProfileStatus.saved,
        profile: updatedProfile,
        fullName: updatedProfile.fullName,
        weightInput: '${updatedProfile.weight}',
        heightInput: _formatHeight(updatedProfile.height),
        clearErrorMessage: true,
      ),
    );
  }

  static String _formatHeight(int heightInCm) {
    if (heightInCm >= 100) {
      return (heightInCm / 100).toStringAsFixed(2);
    }
    return '$heightInCm';
  }

  static int? _parseWeight(String input) {
    final normalized = input.replaceAll(RegExp(r'[^0-9.]'), '');
    if (normalized.isEmpty) {
      return null;
    }
    final value = double.tryParse(normalized);
    return value?.round();
  }

  static int? _parseHeight(String input) {
    final normalized = input.replaceAll(RegExp(r'[^0-9.]'), '');
    if (normalized.isEmpty) {
      return null;
    }
    final value = double.tryParse(normalized);
    if (value == null) {
      return null;
    }
    if (value < 3) {
      return (value * 100).round();
    }
    return value.round();
  }
}
