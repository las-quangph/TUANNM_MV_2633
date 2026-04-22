import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/storage/avatar_storage.dart';
import '../../common/storage/user_profile_storage.dart';
import 'info_user_event.dart';
import 'info_user_state.dart';

class InfoUserBloc extends Bloc<InfoUserEvent, InfoUserState> {
  InfoUserBloc({
    ImagePicker? imagePicker,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        super(const InfoUserState()) {
    on<SetInfoUserPageIndex>((event, emit) {
      emit(state.copyWith(pageIndex: event.index));
    });
    on<SelectInfoUserGender>((event, emit) {
      emit(state.copyWith(gender: event.gender));
    });
    on<SetInfoUserAge>((event, emit) {
      emit(state.copyWith(age: event.age));
    });
    on<SetInfoUserWeight>((event, emit) {
      emit(state.copyWith(weight: event.weight));
    });
    on<SetInfoUserHeight>((event, emit) {
      emit(state.copyWith(height: event.height));
    });
    on<SetInfoUserGoal>((event, emit) {
      emit(state.copyWith(goal: event.goal));
    });
    on<SetInfoUserFullName>((event, emit) {
      emit(state.copyWith(fullName: event.value));
    });
    on<SetInfoUserNickName>((event, emit) {
      emit(state.copyWith(nickName: event.value));
    });
    on<PickInfoUserProfileImage>(_onPickInfoUserProfileImage);
    on<SaveInfoUserProfile>(_onSaveInfoUserProfile);
  }

  final ImagePicker _imagePicker;

  Future<void> _onPickInfoUserProfileImage(
    PickInfoUserProfileImage event,
    Emitter<InfoUserState> emit,
  ) async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    final persistedAvatarPath = await AvatarStorage.persistAvatar(image.path);

    emit(state.copyWith(profileImagePath: persistedAvatarPath));
  }

  Future<void> _onSaveInfoUserProfile(
    SaveInfoUserProfile event,
    Emitter<InfoUserState> emit,
  ) async {
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
