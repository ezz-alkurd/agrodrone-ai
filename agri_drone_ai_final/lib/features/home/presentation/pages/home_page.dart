import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_state.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/status_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late Animation<double> _heroOpacity;
  late Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadStatus();
    context.read<NotificationsCubit>().load();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heroOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroCtrl, curve: const Interval(0, 0.6)),
    );
    _heroSlide = Tween(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));

    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        color: cs.primary,
        backgroundColor: Theme.of(context).cardTheme.color,
        onRefresh: () => context.read<HomeCubit>().refresh(),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(child: _buildHeroBanner(context, cs)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppDimensions.spaceMD),
                  _buildStatusSection(context),
                  const SizedBox(height: AppDimensions.spaceLG),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  _buildQuickActions(context, cs),
                  const SizedBox(height: AppDimensions.spaceXL),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      automaticallyImplyLeading: false,
      titleSpacing: AppDimensions.spaceMD,
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (ctx, state) {
          if (state is AuthAuthenticated) {
            return ProfileHeader(user: state.user);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, ColorScheme cs) {
    return FadeTransition(
      opacity: _heroOpacity,
      child: SlideTransition(
        position: _heroSlide,
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            AppDimensions.spaceMD,
            AppDimensions.spaceMD,
            AppDimensions.spaceMD,
            0,
          ),
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            gradient: LinearGradient(
              colors: [
                cs.primary.withOpacity(0.85),
                cs.secondary.withOpacity(0.65),
                cs.primary.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceMD),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: const Icon(
                        Icons.agriculture_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'AgroDrone AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI-powered farm monitoring',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              _HeroBadge(label: 'Live'),
                              SizedBox(width: 8),
                              _HeroBadge(
                                label: 'Secure',
                                icon: Icons.shield_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (ctx, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return _ShimmerCard(
            height: 160,
            baseColor: Theme.of(context).cardTheme.color ?? AppColors.backgroundCard,
          );
        }
        if (state is HomeLoaded) return DroneStatusCard(status: state.status);
        if (state is HomeError) {
          return _ErrorCard(
            message: state.message,
            onRetry: () => ctx.read<HomeCubit>().loadStatus(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, ColorScheme cs) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (ctx, notifState) {
        final unread = notifState is NotificationsLoaded ? notifState.unreadCount : 0;

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppDimensions.spaceMD,
          mainAxisSpacing: AppDimensions.spaceMD,
          childAspectRatio: 1.2,
          children: [
            QuickActionCard(
              icon: Icons.map_outlined,
              title: 'Live Map',
              subtitle: 'Track drone & view alerts',
              accentColor: cs.primary,
              onTap: () => context.go('/map'),
            ),
            QuickActionCard(
              icon: Icons.biotech_outlined,
              title: 'AI Diagnosis',
              subtitle: 'Scan plant for disease',
              accentColor: const Color(0xFF7C3AED),
              onTap: () => context.go('/ai-diagnostic'),
            ),
            QuickActionCard(
              icon: Icons.notifications_outlined,
              title: 'Alerts',
              subtitle: 'Real-time notifications',
              accentColor: AppColors.alertFire,
              onTap: () => context.go('/notifications'),
              badge: CountBadge(count: unread),
            ),
            QuickActionCard(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Theme & preferences',
              accentColor: cs.secondary,
              onTap: () => context.go('/settings'),
            ),
          ],
        );
      },
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HeroBadge({
    required this.label,
    this.icon = Icons.fiber_manual_record,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double height;
  final Color baseColor;
  const _ShimmerCard({required this.height, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: baseColor.withOpacity(0.6),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.alertFireFaint,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.alertFire.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.alertFire),
          const SizedBox(width: AppDimensions.spaceSM),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}
