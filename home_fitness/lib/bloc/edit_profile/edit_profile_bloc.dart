import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/storage/avatar_storage.dart';
import '../../common/storage/user_profile_storage.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc({
    ImagePicker? imagePicker,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        super(const EditProfileState()) {
    on<LoadEditProfile>(_onLoadEditProfile);
    on<SetEditProfileFullName>((event, emit) {
      emit(state.copyWith(fullName: event.value, clearErrorMessage: true));
    });
    on<SetEditProfileWeightInput>((event, emit) {
      emit(state.copyWith(weightInput: event.value, clearErrorMessage: true));
    });
    on<SetEditProfileHeightInput>((event, emit) {
      emit(state.copyWith(heightInput: event.value, clearErrorMessage: true));
    });
    on<PickEditProfileAvatar>(_onPickEditProfileAvatar);
    on<SaveEditProfile>(_onSaveEditProfile);
  }

  final ImagePicker _imagePicker;

  Future<void> _onLoadEditProfile(
    LoadEditProfile event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: EditProfileStatus.loading,
        clearErrorMessage: true,
      ),
    );

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

  Future<void> _onPickEditProfileAvatar(
    PickEditProfileAvatar event,
    Emitter<EditProfileState> emit,
  ) async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    final persistedAvatarPath = await AvatarStorage.persistAvatar(image.path);

    emit(
      state.copyWith(
        profile: state.profile.copyWith(avatarPath: persistedAvatarPath),
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onSaveEditProfile(
    SaveEditProfile event,
    Emitter<EditProfileState> emit,
  ) async {
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

    emit(
      state.copyWith(
        status: EditProfileStatus.saving,
        clearErrorMessage: true,
      ),
    );

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
