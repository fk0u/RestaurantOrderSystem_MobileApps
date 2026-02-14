import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import '../../../../core/input/toaster.dart';
import '../../../../core/theme/design_system.dart';

class LoginScreen extends ConsumerStatefulWidget {
  // Trigger reload
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // For register
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        ref
            .read(authControllerProvider.notifier)
            .login(_emailController.text, _passwordController.text);
      } else {
        // Register
        ref
            .read(authControllerProvider.notifier)
            .register(
              _nameController.text,
              _emailController.text,
              _passwordController.text,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Listen to errors
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        Toaster.showError(
          context,
          next.error.toString().replaceAll('Exception: ', ''),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.s21),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimens.r32),
                      boxShadow: AppShadows.float,
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppDimens.s34),

                  // Welcome Text
                  Text(
                    'Selamat Datang',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.s8),
                  Text(
                    'Nikmati makanan lezat dalam satu sentuhan',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.s34),

                  // Tab Switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppDimens.r24),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Masuk'),
                        Tab(text: 'Daftar'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.s21),

                  // Form
                  Form(
                    key: _formKey,
                    child: AnimatedBuilder(
                      animation: _tabController.animation!,
                      builder: (context, child) {
                        return Column(
                          children: [
                            // Register Name Field
                            if (_tabController.index == 1) ...[
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Lengkap',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (v) =>
                                    _tabController.index == 1 &&
                                        (v == null || v.isEmpty)
                                    ? 'Harap isi nama'
                                    : null,
                              ),
                              const SizedBox(height: AppDimens.s16),
                            ],

                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Pengguna / Email',
                                prefixIcon: Icon(Icons.alternate_email),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Harap isi email'
                                  : null,
                            ),
                            const SizedBox(height: AppDimens.s16),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Kata Sandi',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Harap isi kata sandi'
                                  : null,
                            ),
                            const SizedBox(height: AppDimens.s34),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: authState.isLoading ? null : _submit,
                                style:
                                    ElevatedButton.styleFrom(
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                    ).copyWith(
                                      elevation: ButtonStyleButton.allOrNull(
                                        0.0,
                                      ),
                                    ),
                                child: authState.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        _tabController.index == 0
                                            ? 'Masuk Sekarang'
                                            : 'Buat Akun',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppDimens.s21),
                  if (_tabController.index == 0)
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
