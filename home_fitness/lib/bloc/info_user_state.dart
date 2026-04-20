class InfoUserState {
  const InfoUserState({
    this.pageIndex = 0,
    this.gender = InfoUserGender.female,
    this.age = 28,
    this.weight = 75,
    this.height = 165,
    this.goal = 'Lose Weight',
    this.fullName = 'Madison Smith',
    this.nickName = 'Madison',
    this.profileImagePath,
    this.status = InfoUserStatus.idle,
  });

  final int pageIndex;
  final InfoUserGender gender;
  final int age;
  final int weight;
  final int height;
  final String goal;
  final String fullName;
  final String nickName;
  final String? profileImagePath;
  final InfoUserStatus status;

  String get initials {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return 'U';
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.first.substring(0, 1).toUpperCase();
    final second = parts.length > 1 ? parts.last.substring(0, 1).toUpperCase() : '';
    return '$first$second';
  }

  InfoUserState copyWith({
    int? pageIndex,
    InfoUserGender? gender,
    int? age,
    int? weight,
    int? height,
    String? goal,
    String? fullName,
    String? nickName,
    String? profileImagePath,
    bool clearProfileImagePath = false,
    InfoUserStatus? status,
  }) {
    return InfoUserState(
      pageIndex: pageIndex ?? this.pageIndex,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      fullName: fullName ?? this.fullName,
      nickName: nickName ?? this.nickName,
      profileImagePath: clearProfileImagePath
          ? null
          : profileImagePath ?? this.profileImagePath,
      status: status ?? this.status,
    );
  }
}

enum InfoUserGender {
  male,
  female,
}

enum InfoUserStatus {
  idle,
  saving,
  saved,
}
