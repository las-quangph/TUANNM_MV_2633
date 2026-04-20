import '../common/storage/user_profile_storage.dart';

enum EditProfileStatus {
  initial,
  loading,
  ready,
  saving,
  saved,
  failure,
}

class EditProfileState {
  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.profile = const UserProfileData(
      fullName: 'Madison Smith',
      nickName: 'Madison',
      gender: 'female',
      age: 28,
      weight: 75,
      height: 165,
      goal: 'Lose Weight',
    ),
    this.fullName = 'Madison Smith',
    this.weightInput = '75',
    this.heightInput = '1.65',
    this.errorMessage,
  });

  final EditProfileStatus status;
  final UserProfileData profile;
  final String fullName;
  final String weightInput;
  final String heightInput;
  final String? errorMessage;

  String? get avatarPath => profile.avatarPath;

  EditProfileState copyWith({
    EditProfileStatus? status,
    UserProfileData? profile,
    String? fullName,
    String? weightInput,
    String? heightInput,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      fullName: fullName ?? this.fullName,
      weightInput: weightInput ?? this.weightInput,
      heightInput: heightInput ?? this.heightInput,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
