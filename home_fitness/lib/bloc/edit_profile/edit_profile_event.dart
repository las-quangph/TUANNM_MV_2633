abstract class EditProfileEvent {
  const EditProfileEvent();
}

class LoadEditProfile extends EditProfileEvent {
  const LoadEditProfile();
}

class SetEditProfileFullName extends EditProfileEvent {
  const SetEditProfileFullName(this.value);

  final String value;
}

class SetEditProfileWeightInput extends EditProfileEvent {
  const SetEditProfileWeightInput(this.value);

  final String value;
}

class SetEditProfileHeightInput extends EditProfileEvent {
  const SetEditProfileHeightInput(this.value);

  final String value;
}

class PickEditProfileAvatar extends EditProfileEvent {
  const PickEditProfileAvatar();
}

class SaveEditProfile extends EditProfileEvent {
  const SaveEditProfile();
}
