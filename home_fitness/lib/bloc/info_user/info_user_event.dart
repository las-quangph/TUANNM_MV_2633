import 'info_user_state.dart';

abstract class InfoUserEvent {
  const InfoUserEvent();
}

class SetInfoUserPageIndex extends InfoUserEvent {
  const SetInfoUserPageIndex(this.index);

  final int index;
}

class SelectInfoUserGender extends InfoUserEvent {
  const SelectInfoUserGender(this.gender);

  final InfoUserGender gender;
}

class SetInfoUserAge extends InfoUserEvent {
  const SetInfoUserAge(this.age);

  final int age;
}

class SetInfoUserWeight extends InfoUserEvent {
  const SetInfoUserWeight(this.weight);

  final int weight;
}

class SetInfoUserHeight extends InfoUserEvent {
  const SetInfoUserHeight(this.height);

  final int height;
}

class SetInfoUserGoal extends InfoUserEvent {
  const SetInfoUserGoal(this.goal);

  final String goal;
}

class SetInfoUserFullName extends InfoUserEvent {
  const SetInfoUserFullName(this.value);

  final String value;
}

class SetInfoUserNickName extends InfoUserEvent {
  const SetInfoUserNickName(this.value);

  final String value;
}

class PickInfoUserProfileImage extends InfoUserEvent {
  const PickInfoUserProfileImage();
}

class SaveInfoUserProfile extends InfoUserEvent {
  const SaveInfoUserProfile();
}
