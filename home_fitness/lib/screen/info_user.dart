import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/info_user_state.dart';
import '../route/app_routes.dart';
import '../values/app_assets.dart';
import '../bloc/info_user_cubit.dart';

const _infoUserAccentColor = Color(0xFFE7FF57);
const _infoUserMinHeight = 120;
const _infoUserMaxHeight = 200;

class InfoUser extends StatelessWidget {
  const InfoUser({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InfoUserCubit(),
      child: const _InfoUserView(),
    );
  }
}

class _InfoUserView extends StatefulWidget {
  const _InfoUserView();

  @override
  State<_InfoUserView> createState() => _InfoUserViewState();
}

class _InfoUserViewState extends State<_InfoUserView> {
  static const Color _bgColor = Color(0xFF232323);
  static const Color _accentColor = Color(0xFFE7FF57);
  static const int _minHeight = 120;
  static const int _maxHeight = 200;
  static const double _heightSelectorViewport = 370;

  final PageController _pageController = PageController();
  late final PageController _ageController;
  late final PageController _weightController;
  late final FixedExtentScrollController _heightController;
  final TextEditingController _fullNameController = TextEditingController(
    text: 'Madison Smith',
  );
  final TextEditingController _nickNameController = TextEditingController(
    text: 'Madison',
  );

  final List<String> _goals = const [
    'Lose Weight',
    'Gain Weight',
    'Muscle Mass Gain',
    'Shape Body',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<InfoUserCubit>().state;
    _ageController = PageController(
      initialPage: state.age - 1,
      viewportFraction: 0.2,
    );
    _weightController = PageController(
      initialPage: state.weight - 1,
      viewportFraction: 0.2,
    );
    _heightController = FixedExtentScrollController(initialItem: _maxHeight - state.height);
    _fullNameController.text = state.fullName;
    _nickNameController.text = state.nickName;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _fullNameController.dispose();
    _nickNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InfoUserCubit, InfoUserState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == InfoUserStatus.saved) {
          context.go(AppRoutes.home);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _bgColor,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: context.read<InfoUserCubit>().setPageIndex,
                    children: [
                      _buildGenderPage(state),
                      _buildAgePage(state),
                      _buildWeightPage(state),
                      _buildHeightPage(state),
                      _buildGoalPage(state),
                      _buildProfilePage(state),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderPage(InfoUserState state) {
    return _FlowScaffold(
      title: "What's Your Gender",
      onBack: state.pageIndex == 0 ? null : _goToPrevious,
      footer: _buildActionButton(label: 'Continue', onTap: _goToNext),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _GenderOption(
            label: 'Male',
            iconAsset: AppIcons.icMale,
            selected: state.gender == InfoUserGender.male,
            onTap: () => context.read<InfoUserCubit>().selectGender(InfoUserGender.male),
          ),
          const SizedBox(height: 18),
          _GenderOption(
            label: 'Female',
            iconAsset: AppIcons.icFemale,
            selected: state.gender == InfoUserGender.female,
            onTap: () => context.read<InfoUserCubit>().selectGender(InfoUserGender.female),
          ),
        ],
      ),
    );
  }

  Widget _buildAgePage(InfoUserState state) {
    return _FlowScaffold(
      title: 'How Old Are You?',
      onBack: _goToPrevious,
      footer: _buildActionButton(label: 'Continue', onTap: _goToNext),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            '${state.age}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Icon(Icons.keyboard_arrow_up_rounded, color: _accentColor, size: 24),
          const SizedBox(height: 10),
          SizedBox(
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Column(
                    children: const [
                      Divider(color: _accentColor, thickness: 2, height: 2),
                      Spacer(),
                      Divider(color: _accentColor, thickness: 2, height: 2),
                    ],
                  ),
                ),
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 64,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: _accentColor,
                        border: Border(
                          left: BorderSide(color: Colors.black.withValues(alpha: 0.85)),
                          right: BorderSide(color: Colors.black.withValues(alpha: 0.85)),
                        ),
                      ),
                    ),
                  ),
                ),
                PageView.builder(
                  controller: _ageController,
                  itemCount: 100,
                  onPageChanged: (index) =>
                      context.read<InfoUserCubit>().setAge(index + 1),
                  itemBuilder: (context, index) {
                    final value = index + 1;
                    final selected = value == state.age;
                    return Center(
                      child: Text(
                        '$value',
                        style: TextStyle(
                          color: selected ? Colors.black : const Color(0xFF8A8A8A),
                          fontSize: selected ? 22 : 18,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPage(InfoUserState state) {
    return _FlowScaffold(
      title: 'What Is Your Weight?',
      onBack: _goToPrevious,
      footer: _buildActionButton(label: 'Continue', onTap: _goToNext),
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: PageView.builder(
              controller: _weightController,
              itemCount: 151,
              onPageChanged: (index) =>
                  context.read<InfoUserCubit>().setWeight(index + 1),
              itemBuilder: (context, index) {
                final value = index + 1;
                final selected = value == state.weight;
                return Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF8A8A8A),
                      fontSize: selected ? 20 : 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 78,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    AppIcons.icRule1,
                    height: 50,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  top: 58,
                  child: Image.asset(
                    AppIcons.icPolygon,
                    width: 28,
                    height: 20,
                    color: _accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${state.weight}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const TextSpan(
                  text: ' Kg',
                  style: TextStyle(
                    color: Color(0xFFA1A1A1),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightPage(InfoUserState state) {
    return _FlowScaffold(
      title: 'What Is Your Height?',
      onBack: _goToPrevious,
      footer: _buildActionButton(label: 'Continue', onTap: _goToNext),
      child: SizedBox(
        width: 230,
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${state.height}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(
                    text: ' Cm',
                    style: TextStyle(
                      color: Color(0xFFA1A1A1),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: _heightSelectorViewport,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 78,
                    child: ListWheelScrollView.useDelegate(
                      controller: _heightController,
                      itemExtent: 48,
                      diameterRatio: 10,
                      physics: const FixedExtentScrollPhysics(),
                      overAndUnderCenterOpacity: 0.7,
                      perspective: 0.001,
                      onSelectedItemChanged: (index) => context
                          .read<InfoUserCubit>()
                          .setHeight(_maxHeight - index),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _maxHeight - _minHeight + 1,
                        builder: (context, index) {
                          final value = _maxHeight - index;
                          final selected = value == state.height;
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$value',
                              style: TextStyle(
                                color: selected ? Colors.white : const Color(0xFF8A8A8A),
                                fontSize: selected ? 34 : 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const _HeightSelector(height: _heightSelectorViewport),
                  const SizedBox(width: 12),
                  const _HeightPointer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalPage(InfoUserState state) {
    return _FlowScaffold(
      title: 'What Is Your Goal?',
      onBack: _goToPrevious,
      footer: _buildActionButton(label: 'Continue', onTap: _goToNext),
      child: OverflowBox(
        alignment: Alignment.center,
        minWidth: MediaQuery.of(context).size.width,
        maxWidth: MediaQuery.of(context).size.width,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 50, 28, 50),
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _goals.map((goal) {
                final selected = goal == state.goal;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => context.read<InfoUserCubit>().setGoal(goal),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black54, width: 2),
                              color: selected ? _accentColor : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePage(InfoUserState state) {
    final profileImage = state.profileImagePath == null
        ? null
        : File(state.profileImagePath!);

    return _FlowScaffold(
      title: 'Fill Your Profile',
      onBack: _goToPrevious,
      footer: _buildActionButton(
        label: state.status == InfoUserStatus.saving ? 'Saving' : 'Start',
        onTap: state.status == InfoUserStatus.saving ? null : _goToHome,
        highlighted: true,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => context.read<InfoUserCubit>().pickProfileImage(),
            borderRadius: BorderRadius.circular(80),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: profileImage == null
                        ? const LinearGradient(
                            colors: [Color(0xFFE8E8E8), Color(0xFF8D8D8D)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    border: Border.all(color: Colors.white12),
                    image: profileImage == null
                        ? null
                        : DecorationImage(
                            image: FileImage(profileImage),
                            fit: BoxFit.cover,
                          ),
                  ),
                  alignment: Alignment.center,
                  child: profileImage == null
                      ? Text(
                          state.initials,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      AppIcons.icEdit,
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          _InputField(
            label: 'Full name',
            controller: _fullNameController,
            onChanged: context.read<InfoUserCubit>().setFullName,
          ),
          const SizedBox(height: 12),
          _InputField(
            label: 'Nickname',
            controller: _nickNameController,
            onChanged: context.read<InfoUserCubit>().setNickName,
          ),
          const SizedBox(height: 24),

        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onTap,
    bool highlighted = false,
  }) {
    return SizedBox(
      width: 126,
      height: 42,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: highlighted ? _accentColor : const Color(0xFF3B3B3B),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Colors.white24),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: highlighted ? Colors.black : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _goToNext() {
    if (context.read<InfoUserCubit>().state.pageIndex == 5) {
      _goToHome();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _goToPrevious() {
    if (context.read<InfoUserCubit>().state.pageIndex == 0) {
      return;
    }

    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _goToHome() async {
    await context.read<InfoUserCubit>().saveProfile();
  }
}

class _FlowScaffold extends StatelessWidget {
  const _FlowScaffold({
    required this.title,
    required this.child,
    required this.footer,
    this.onBack,
  });

  final String title;
  final Widget child;
  final Widget footer;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
      child: Column(
        children: [
          Row(
            children: [
              if (onBack == null)
                const SizedBox(width: 28, height: 28)
              else
                InkWell(
                  onTap: onBack,
                  child: Image.asset(
                    AppIcons.icBack,
                    width: 60,
                    height: 28,
                    color: _infoUserAccentColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(child: Center(child: child)),
          footer,
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 160,
          height: 160,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? const Color(0xFFE2F163) : Colors.white54,
              width: 1.5,
            ),
          ),
          child: Image.asset(
            iconAsset,
            width: 80,
              height: 80,
              color: selected ? const Color(0xFFE2F163) : Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8F64FF),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeightSelector extends StatelessWidget {
  const _HeightSelector({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: height,
      decoration: BoxDecoration(
        color: _infoUserAccentColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: CustomPaint(
        size: Size(70, height),
        painter: const _HeightScalePainter(
          min: _infoUserMinHeight,
          max: _infoUserMaxHeight,
        ),
      ),
    );
  }
}

class _HeightPointer extends StatelessWidget {
  const _HeightPointer();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppIcons.icLeftPolygon,
      width: 22,
      height: 22,
      color: _infoUserAccentColor,
    );
  }
}

class _HeightScalePainter extends CustomPainter {
  const _HeightScalePainter({
    required this.min,
    required this.max,
  });

  final int min;
  final int max;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    final total = max - min;
    for (int i = 0; i <= total; i++) {
      final y = size.height - ((i / total) * size.height);
      final isMajor = i % 5 == 0;
      final length = isMajor ? 28.0 : 16.0;
      canvas.drawLine(
        Offset(size.width / 2 - (length / 2), y),
        Offset(size.width / 2 + (length / 2), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeightScalePainter oldDelegate) {
    return false;
  }
}
