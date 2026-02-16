import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'auth_controller.dart';
import 'bloc/auth_state.dart';
import '../../../../core/input/toaster.dart';
import '../../../../core/theme/design_system.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update button text/validation logic
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_tabController.index == 0) {
        // Login
        context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
      } else {
        // Register (Simulated for now, or map to RegisterRequested if it exists)
        // For this task, we focus on Login migration.
        // Assuming Register calls same or similar API.
        // If AuthRegisterRequested doesn't exist yet, we might need to add it.
        // For now, let's treat it as a TODO or handle via generic login for prototype
        Toaster.showError(
          context,
          "Registrasi belum dimigrasikan ke BLoC sepenuhnya.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) async {
              if (state is AuthAuthenticated) {
                // Sync Riverpod state for AppRouter
                await ref.read(authControllerProvider.notifier).checkSession();

                if (!context.mounted) return;
                final user = state.user;
                if (user.role == 'admin') {
                  context.go('/admin');
                } else if (user.role == 'kitchen') {
                  context.go('/kitchen');
                } else if (user.role == 'cashier') {
                  context.go('/cashier');
                } else {
                  context.go('/order-type');
                }
              }
              if (state is AuthFailure) {
                Toaster.showError(
                  context,
                  state.message.replaceAll('Exception: ', ''),
                );
              }
            },
            child: child,
          );
        },
        child: Stack(
          children: [
            // Immersive Animated Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.background, Color(0xFFE0F7FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -100,
              right: -100,
              child:
                  Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        duration: 4.seconds,
                        begin: const Offset(1, 1),
                        end: const Offset(1.1, 1.1),
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        duration: 4.seconds,
                        begin: const Offset(1.1, 1.1),
                        end: const Offset(1, 1),
                        curve: Curves.easeInOut,
                      ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.s21),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(
                                  AppDimens.r32,
                                ),
                                boxShadow: AppShadows.float,
                              ),
                              child: const Icon(
                                Icons.restaurant_menu_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(delay: 200.ms, curve: Curves.elasticOut),
                        const SizedBox(height: AppDimens.s34),

                        // Welcome Text
                        Text(
                              'Selamat Datang',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            )
                            .animate()
                            .fadeIn(delay: 400.ms)
                            .moveY(begin: 20, end: 0),
                        const SizedBox(height: AppDimens.s8),
                        Text(
                              'Nikmati makanan lezat dalam satu sentuhan',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.textSecondary),
                            )
                            .animate()
                            .fadeIn(delay: 500.ms)
                            .moveY(begin: 20, end: 0),
                        const SizedBox(height: AppDimens.s34),

                        // Glassmorphism Card
                        Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.05,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Tab Switcher
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(
                                          AppDimens.r24,
                                        ),
                                      ),
                                      child: TabBar(
                                        controller: _tabController,
                                        indicator: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        labelColor: AppColors.primary,
                                        unselectedLabelColor:
                                            AppColors.textSecondary,
                                        dividerColor: Colors.transparent,
                                        tabs: const [
                                          Tab(text: 'Masuk'),
                                          Tab(text: 'Daftar'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Animated Form Fields
                                    AnimatedSize(
                                      duration: 300.ms,
                                      curve: Curves.easeInOut,
                                      child: Column(
                                        children: [
                                          if (_tabController.index == 1) ...[
                                            TextFormField(
                                              controller: _nameController,
                                              enabled: !isLoading,
                                              decoration: InputDecoration(
                                                labelText: 'Nama Lengkap',
                                                prefixIcon: const Icon(
                                                  Icons.person_outline,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  borderSide: BorderSide.none,
                                                ),
                                                filled: true,
                                                fillColor:
                                                    AppColors.surfaceLight,
                                              ),
                                              validator: (v) =>
                                                  _tabController.index == 1 &&
                                                      (v == null || v.isEmpty)
                                                  ? 'Harap isi nama'
                                                  : null,
                                            ).animate().fadeIn().moveX(
                                              begin: -20,
                                              end: 0,
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                          TextFormField(
                                            controller: _emailController,
                                            enabled: !isLoading,
                                            decoration: InputDecoration(
                                              labelText: 'Email',
                                              prefixIcon: const Icon(
                                                Icons.alternate_email,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: AppColors.surfaceLight,
                                            ),
                                            validator: (v) =>
                                                v == null || v.isEmpty
                                                ? 'Harap isi email'
                                                : null,
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _passwordController,
                                            enabled: !isLoading,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              labelText: 'Kata Sandi',
                                              prefixIcon: const Icon(
                                                Icons.lock_outline,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: AppColors.surfaceLight,
                                            ),
                                            validator: (v) =>
                                                v == null || v.isEmpty
                                                ? 'Harap isi kata sandi'
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Action Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 8,
                                          shadowColor: AppColors.primary
                                              .withValues(alpha: 0.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                _tabController.index == 0
                                                    ? 'Masuk'
                                                    : 'Daftar',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 600.ms)
                            .moveY(begin: 50, end: 0),

                        const SizedBox(height: 24),
                        if (_tabController.index == 0)
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Lupa Kata Sandi?',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ).animate().fadeIn(delay: 800.ms),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
