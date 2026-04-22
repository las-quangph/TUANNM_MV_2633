import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/edit_profile/edit_profile_bloc.dart';
import '../bloc/edit_profile/edit_profile_event.dart';
import '../bloc/edit_profile/edit_profile_state.dart';
import '../common/ext/device_ext.dart';
import '../ui_view/profile_header_view.dart';
import '../values/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileBloc()..add(const LoadEditProfile()),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileBloc, EditProfileState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.fullName != current.fullName ||
          previous.weightInput != current.weightInput ||
          previous.heightInput != current.heightInput,
      listener: (context, state) {
        _syncControllers(state);

        if (state.status == EditProfileStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }

        if (state.status == EditProfileStatus.saved) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final bloc = context.read<EditProfileBloc>();

        return Scaffold(
          backgroundColor: AppColors.bgColor,
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.translucent,
            child: SafeArea(
              child:
                  state.status == EditProfileStatus.loading ||
                      state.status == EditProfileStatus.initial
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE8FF54),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.only(bottom: 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    12,
                                    16,
                                    28,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      icon: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: Color(0xFFE8FF54),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                ProfileHeaderView(
                                  profile: state.profile.copyWith(
                                    fullName: state.fullName.trim().isEmpty
                                        ? state.profile.fullName
                                        : state.fullName.trim(),
                                  ),
                                  avatarPath: state.avatarPath,
                                  onEditAvatar: () {
                                    bloc.add(const PickEditProfileAvatar());
                                  },
                                  headerPadding: const EdgeInsets.fromLTRB(
                                    24,
                                    24,
                                    24,
                                    48,
                                  ),
                                  statsHorizontalPadding: 18,
                                  statsVerticalPadding: 12,
                                  statsLeft: 24,
                                  statsRight: 24,
                                  statsColor: const Color(0xFF9DDB48),
                                  showBottomSpacer: false,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    48,
                                    24,
                                    0,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 20),
                                      _InputField(
                                        label: 'Username',
                                        controller: _fullNameController,
                                        keyboardType: TextInputType.name,
                                        onChanged: (value) {
                                          bloc.add(
                                            SetEditProfileFullName(value),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 18),
                                      _InputField(
                                        label: 'Weight',
                                        controller: _weightController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        suffixText: 'Kg',
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.]'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          bloc.add(
                                            SetEditProfileWeightInput(value),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 18),
                                      _InputField(
                                        label: 'Height',
                                        controller: _heightController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        suffixText: 'CM',
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.]'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          bloc.add(
                                            SetEditProfileHeightInput(value),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 26),
                                      SizedBox(
                                        width: context.isPhone ? 180 : 250,
                                        height: context.isPhone ? 50 : 80,
                                        child: ElevatedButton(
                                          onPressed:
                                              state.status ==
                                                  EditProfileStatus.saving
                                              ? null
                                              : () {
                                                  FocusManager
                                                      .instance
                                                      .primaryFocus
                                                      ?.unfocus();
                                                  bloc.add(
                                                    const SaveEditProfile(),
                                                  );
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFE8FF54,
                                            ),
                                            foregroundColor: Colors.black,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                          child: Text(
                                            state.status ==
                                                    EditProfileStatus.saving
                                                ? 'Saving...'
                                                : 'Update Profile',
                                            style: TextStyle(
                                              fontSize: context.isPhone ? 15 : 25,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  void _syncControllers(EditProfileState state) {
    _syncController(_fullNameController, state.fullName);
    _syncController(_weightController, state.weightInput);
    _syncController(_heightController, state.heightInput);
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }

    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.onChanged,
    this.suffixText,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF9DDB48),
            fontSize: context.isPhone ? 16 : 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          scrollPadding: const EdgeInsets.only(bottom: 20),
          style: TextStyle(
            color: Color(0xFF303030),
            fontSize: context.isPhone ? 15 : 25,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            suffixText: suffixText,
            suffixStyle: TextStyle(
              color: Color(0xFF303030),
              fontSize: context.isPhone ? 15 : 25,
              fontWeight: FontWeight.w700,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
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
