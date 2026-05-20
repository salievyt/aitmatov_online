import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/controllers/async_controller.dart';
import '../../../core/constans/constants.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../auth/bloc/auth_bloc.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final AsyncController<User> _controller;

  @override
  void initState() {
    super.initState();
    _controller = AsyncController(loader: () => context.read<AuthRepository>().getUserProfile(widget.userId));
    _controller.load().then((_) {
      if (!mounted && _controller.state.value.hasError) return;
      if (_controller.state.value.hasError) {
        _showReloginDialog();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async => _controller.load();

  void _showReloginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
          ),
          elevation: AppSizes.elevationDialog,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.dialogWhite,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.dialogPaddingDefault),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppSizes.iconContainerSize,
                    height: AppSizes.iconContainerSize,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: AppSizes.iconXL,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionSpacing),
                  Text(
                    'Сессия истекла',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.itemSpacing),
                  Text(
                    'Не удалось загрузить данные профиля.\nПожалуйста, заново войдите в аккаунт.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.dialogPaddingDefault),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.buttonPaddingVertical),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                        ),
                        elevation: AppSizes.elevationCard,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                      child: const Text(
                        'Войти снова',
                        style: TextStyle(
                          fontSize: AppTypography.buttonTextSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
          ),
          elevation: AppSizes.elevationDialog,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.dialogWhite,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.dialogPaddingDefault),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppSizes.iconContainerSize,
                    height: AppSizes.iconContainerSize,
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      size: AppSizes.iconXL,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionSpacing),
                  Text(
                    'Выход из аккаунта',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.itemSpacing),
                  Text(
                    'Вы уверены, что хотите выйти?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.dialogPaddingDefault),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.buttonPaddingVertical),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                            ),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Отмена',
                            style: TextStyle(
                              fontSize: AppTypography.buttonTextSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.itemSpacing),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: AppColors.textOnPrimary,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.buttonPaddingVertical),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                            ),
                            elevation: AppSizes.elevationCard,
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Выйти',
                            style: TextStyle(
                              fontSize: AppTypography.buttonTextSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      if (mounted) {
        context.read<AuthBloc>().add(AuthLogoutRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AsyncState<User>>(
      valueListenable: _controller.state,
      builder: (context, state, child) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Профиль')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.error ?? 'Ошибка загрузки профиля',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          );
        }

        final user = state.data;
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Профиль недоступен'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Профиль'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: _logout,
                tooltip: 'Выход',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              children: [
                CircleAvatar(
                  radius: AppSizes.avatarMedium,
                  backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                  child: user.avatarUrl == null ? Text(user.firstName[0]) : null,
                ),
                const SizedBox(height: AppSpacing.itemSpacing),
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(user.displayName),
              ],
            ),
          ),
        );
      },
    );
  }
}
