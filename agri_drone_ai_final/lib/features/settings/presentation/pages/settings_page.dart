import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/settings_tile.dart';
import '../widgets/theme_picker.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (ctx, settings) {
          return ListView(
            children: [
              _SectionHeader(title: 'Choose Theme', primary: cs.primary),
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
                child: ThemePicker(
                  selectedId: settings.appTheme,
                  onThemeSelected: (id) =>
                      ctx.read<SettingsCubit>().setAppTheme(id),
                ),
              ),
              _SectionHeader(title: 'Language', primary: cs.primary),
              _Card(
                primary: cs.primary,
                child: SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: settings.languageCode == 'ar'
                      ? 'Arabic - العربية'
                      : 'English',
                  trailing: _LanguageToggle(
                    code: settings.languageCode,
                    primary: cs.primary,
                    onChanged: (c) => ctx.read<SettingsCubit>().setLanguage(c),
                  ),
                ),
              ),
              _SectionHeader(title: 'Notifications', primary: cs.primary),
              _Card(
                primary: cs.primary,
                child: SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Fire & disease alerts via FCM',
                  trailing: Switch(
                    value: settings.pushNotificationsEnabled,
                    onChanged: (v) =>
                        ctx.read<SettingsCubit>().setPushNotifications(v),
                  ),
                ),
              ),
              _SectionHeader(title: 'Account', primary: cs.primary),
              _Card(
                primary: cs.primary,
                child: SettingsTile(
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.alertFire,
                  title: 'Logout',
                  onTap: () {
                    ctx.read<AuthBloc>().add(const AuthLogoutRequested());
                    context.go('/login');
                  },
                ),
              ),
              _SectionHeader(title: 'About', primary: cs.primary),
              _Card(
                primary: cs.primary,
                child: Column(
                  children: const [
                    SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Version',
                      subtitle: '1.0.0',
                    ),
                    SettingsTile(
                      icon: Icons.code_rounded,
                      title: 'Architecture',
                      subtitle: 'Clean Arch · BLoC/Cubit · GoRouter',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXXL),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color primary;
  const _SectionHeader({required this.title, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.spaceMD,
          AppDimensions.spaceLG, AppDimensions.spaceMD, AppDimensions.spaceSM),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color primary;
  const _Card({required this.child, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: primary.withOpacity(0.12)),
      ),
      child: child,
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final String code;
  final Color primary;
  final ValueChanged<String> onChanged;

  const _LanguageToggle({
    required this.code,
    required this.primary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Pill(label: 'EN', selected: code == 'en', primary: primary, onTap: () => onChanged('en')),
        const SizedBox(width: 4),
        _Pill(label: 'AR', selected: code == 'ar', primary: primary, onTap: () => onChanged('ar')),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
              color: selected ? primary : primary.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class SettingsSectionHeader extends StatelessWidget {
  final String title;
  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) => _SectionHeader(
        title: title,
        primary: Theme.of(context).colorScheme.primary,
      );
}
