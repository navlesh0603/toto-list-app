// import 'dart:io';

// void main() {
//   print('🚀 Setting up Flutter BLoC Starter Template...\n');

//   // Define the folder structure
//   final directories = [
//     'lib/core/config',
//     'lib/core/constants',
//     'lib/core/network',
//     'lib/core/theme',
//     'lib/core/utils',
//     'lib/features/auth/bloc',
//     'lib/features/auth/data',
//     'lib/features/auth/presentation',
//     'lib/features/home/presentation',
//     'lib/shared/widgets',
//     'lib/routes',
//   ];

//   // Define files to create with basic content
//   final files = {
//     'lib/core/network/dio_client.dart': '''import 'package:dio/dio.dart';

// class DioClient {
//   late final Dio _dio;

//   DioClient() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: 'https://api.example.com',
//         connectTimeout: const Duration(seconds: 5),
//         receiveTimeout: const Duration(seconds: 3),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ),
//     );

//     // Add interceptors if needed
//     _dio.interceptors.add(LogInterceptor(
//       requestBody: true,
//       responseBody: true,
//     ));
//   }

//   Dio get dio => _dio;
// }
// ''',
//     'lib/core/theme/app_theme.dart': '''import 'package:flutter/material.dart';

// class AppTheme {
//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: Colors.blue,
//         brightness: Brightness.light,
//       ),
//       appBarTheme: const AppBarTheme(
//         centerTitle: true,
//         elevation: 0,
//       ),
//     );
//   }

//   static ThemeData get darkTheme {
//     return ThemeData(
//       useMaterial3: true,
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: Colors.blue,
//         brightness: Brightness.dark,
//       ),
//       appBarTheme: const AppBarTheme(
//         centerTitle: true,
//         elevation: 0,
//       ),
//     );
//   }
// }
// ''',
//     'lib/features/auth/bloc/auth_bloc.dart':
//         '''import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import '../data/auth_repository.dart';

// // Events
// abstract class AuthEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class LoginRequested extends AuthEvent {
//   final String email;
//   final String password;

//   LoginRequested({required this.email, required this.password});

//   @override
//   List<Object?> get props => [email, password];
// }

// class SignupRequested extends AuthEvent {
//   final String email;
//   final String password;

//   SignupRequested({required this.email, required this.password});

//   @override
//   List<Object?> get props => [email, password];
// }

// class LogoutRequested extends AuthEvent {}

// // States
// abstract class AuthState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class AuthInitial extends AuthState {}

// class AuthLoading extends AuthState {}

// class AuthAuthenticated extends AuthState {
//   final String userId;

//   AuthAuthenticated({required this.userId});

//   @override
//   List<Object?> get props => [userId];
// }

// class AuthUnauthenticated extends AuthState {}

// class AuthError extends AuthState {
//   final String message;

//   AuthError({required this.message});

//   @override
//   List<Object?> get props => [message];
// }

// // BLoC
// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final AuthRepository authRepository;

//   AuthBloc({required this.authRepository}) : super(AuthInitial()) {
//     on<LoginRequested>(_onLoginRequested);
//     on<SignupRequested>(_onSignupRequested);
//     on<LogoutRequested>(_onLogoutRequested);
//   }

//   Future<void> _onLoginRequested(
//     LoginRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(AuthLoading());
//     try {
//       final userId = await authRepository.login(event.email, event.password);
//       emit(AuthAuthenticated(userId: userId));
//     } catch (e) {
//       emit(AuthError(message: e.toString()));
//     }
//   }

//   Future<void> _onSignupRequested(
//     SignupRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(AuthLoading());
//     try {
//       final userId = await authRepository.signup(event.email, event.password);
//       emit(AuthAuthenticated(userId: userId));
//     } catch (e) {
//       emit(AuthError(message: e.toString()));
//     }
//   }

//   Future<void> _onLogoutRequested(
//     LogoutRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     await authRepository.logout();
//     emit(AuthUnauthenticated());
//   }
// }
// ''',
//     'lib/features/auth/data/auth_repository.dart': '''class AuthRepository {
//   // TODO: Implement actual authentication logic

//   Future<String> login(String email, String password) async {
//     await Future.delayed(const Duration(seconds: 2));
//     // Simulate login
//     if (email.isNotEmpty && password.isNotEmpty) {
//       return 'user_id_123';
//     }
//     throw Exception('Invalid credentials');
//   }

//   Future<String> signup(String email, String password) async {
//     await Future.delayed(const Duration(seconds: 2));
//     // Simulate signup
//     if (email.isNotEmpty && password.isNotEmpty) {
//       return 'user_id_456';
//     }
//     throw Exception('Signup failed');
//   }

//   Future<void> logout() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     // Clear tokens, preferences, etc.
//   }
// }
// ''',
//     'lib/features/auth/presentation/login_screen.dart':
//         '''import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/auth_bloc.dart';
// import '../../../shared/widgets/primary_button.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Login'),
//       ),
//       body: BlocConsumer<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthAuthenticated) {
//             Navigator.pushReplacementNamed(context, '/home');
//           } else if (state is AuthError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is AuthLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TextFormField(
//                     controller: _emailController,
//                     decoration: const InputDecoration(
//                       labelText: 'Email',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter email';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Password',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter password';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   PrimaryButton(
//                     text: 'Login',
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         context.read<AuthBloc>().add(
//                               LoginRequested(
//                                 email: _emailController.text,
//                                 password: _passwordController.text,
//                               ),
//                             );
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/signup');
//                     },
//                     child: const Text('Don\\'t have an account? Sign up'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// ''',
//     'lib/features/auth/presentation/signup_screen.dart':
//         '''import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/auth_bloc.dart';
// import '../../../shared/widgets/primary_button.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sign Up'),
//       ),
//       body: BlocConsumer<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthAuthenticated) {
//             Navigator.pushReplacementNamed(context, '/home');
//           } else if (state is AuthError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is AuthLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TextFormField(
//                     controller: _emailController,
//                     decoration: const InputDecoration(
//                       labelText: 'Email',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter email';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Password',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter password';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   PrimaryButton(
//                     text: 'Sign Up',
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         context.read<AuthBloc>().add(
//                               SignupRequested(
//                                 email: _emailController.text,
//                                 password: _passwordController.text,
//                               ),
//                             );
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Text('Already have an account? Login'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// ''',
//     'lib/features/home/presentation/home_screen.dart':
//         '''import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../auth/bloc/auth_bloc.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               context.read<AuthBloc>().add(LogoutRequested());
//               Navigator.pushReplacementNamed(context, '/login');
//             },
//           ),
//         ],
//       ),
//       body: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.home, size: 64),
//             SizedBox(height: 16),
//             Text(
//               'Welcome Home!',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// ''',
//     'lib/shared/widgets/primary_button.dart':
//         '''import 'package:flutter/material.dart';

// class PrimaryButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final bool isLoading;

//   const PrimaryButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: isLoading ? null : onPressed,
//         child: isLoading
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               )
//             : Text(text),
//       ),
//     );
//   }
// }
// ''',
//     'lib/routes/app_router.dart': '''import 'package:flutter/material.dart';
// import '../features/auth/presentation/login_screen.dart';
// import '../features/auth/presentation/signup_screen.dart';
// import '../features/home/presentation/home_screen.dart';

// class AppRouter {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case '/':
//       case '/login':
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
//       case '/signup':
//         return MaterialPageRoute(builder: (_) => const SignupScreen());
//       case '/home':
//         return MaterialPageRoute(builder: (_) => const HomeScreen());
//       default:
//         return MaterialPageRoute(
//           builder: (_) => Scaffold(
//             body: Center(
//               child: Text('No route defined for \${settings.name}'),
//             ),
//           ),
//         );
//     }
//   }
// }
// ''',
//     'lib/main.dart': '''import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'core/theme/app_theme.dart';
// import 'features/auth/bloc/auth_bloc.dart';
// import 'features/auth/data/auth_repository.dart';
// import 'routes/app_router.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return RepositoryProvider(
//       create: (context) => AuthRepository(),
//       child: BlocProvider(
//         create: (context) => AuthBloc(
//           authRepository: context.read<AuthRepository>(),
//         ),
//         child: MaterialApp(
//           title: 'Flutter BLoC Starter',
//           theme: AppTheme.lightTheme,
//           darkTheme: AppTheme.darkTheme,
//           themeMode: ThemeMode.system,
//           initialRoute: '/login',
//           onGenerateRoute: AppRouter.generateRoute,
//           debugShowCheckedModeBanner: false,
//         ),
//       ),
//     );
//   }
// }
// ''',
//     'pubspec.yaml': '''name: flutter_bloc_starter
// description: A Flutter BLoC starter template project.
// publish_to: 'none'

// version: 1.0.0+1

// environment:
//   sdk: '>=3.0.0 <4.0.0'

// dependencies:
//   flutter:
//     sdk: flutter

//   # State Management
//   flutter_bloc: ^8.1.3
//   equatable: ^2.0.5

//   # Networking
//   dio: ^5.4.0

//   # UI
//   cupertino_icons: ^1.0.2

// dev_dependencies:
//   flutter_test:
//     sdk: flutter
//   flutter_lints: ^3.0.0

// flutter:
//   uses-material-design: true
// ''',
//     'README.md': '''# Flutter BLoC Starter Template

// A well-structured Flutter starter template using the BLoC (Business Logic Component) pattern.

// ## Features

// - ✅ BLoC state management
// - ✅ Feature-first folder structure
// - ✅ Authentication flow (Login/Signup)
// - ✅ Routing setup
// - ✅ Theme configuration
// - ✅ Dio network client
// - ✅ Reusable widgets

// ## Getting Started

// 1. Install dependencies:
//    ```bash
//    flutter pub get
//    ```

// 2. Run the app:
//    ```bash
//    flutter run
//    ```

// ## Project Structure

// ```
// lib/
// ├── core/               # Core utilities, config, theme
// ├── features/           # Feature modules (auth, home, etc.)
// ├── shared/             # Shared widgets and utilities
// ├── routes/             # App routing
// └── main.dart           # App entry point
// ```

// ## Dependencies

// - `flutter_bloc` - State management
// - `equatable` - Value equality
// - `dio` - HTTP client

// ## Next Steps

// - [ ] Add proper API endpoints
// - [ ] Implement token storage
// - [ ] Add error handling
// - [ ] Write tests
// - [ ] Add more features

// ---

// Happy coding! 🚀
// ''',
//   };

//   try {
//     // Create directories
//     print('📁 Creating directories...');
//     for (var dir in directories) {
//       final directory = Directory(dir);
//       if (!directory.existsSync()) {
//         directory.createSync(recursive: true);
//         print('   ✓ Created: $dir');
//       }
//     }

//     print('\n📄 Creating files...');
//     // Create files with content
//     for (var entry in files.entries) {
//       final file = File(entry.key);
//       file.writeAsStringSync(entry.value);
//       print('   ✓ Created: ${entry.key}');
//     }

//     print('\n✅ Flutter BLoC Starter Template setup completed successfully!');
//     print('\n📋 Next steps:');
//     print('   1. Run: flutter pub get');
//     print('   2. Run: flutter run');
//     print('   3. Start building your app! 🚀\n');
//   } catch (e) {
//     print('❌ Error during setup: $e');
//     exit(1);
//   }
// }

import 'dart:io';

void main() {
  print('🚀 Setting up Flutter BLoC Starter Template...\n');

  // Define the folder structure
  final directories = [
    'lib/core/config',
    'lib/core/constants',
    'lib/core/network',
    'lib/core/theme',
    'lib/core/utils',
    'lib/features/auth/bloc',
    'lib/features/auth/data',
    'lib/features/auth/presentation',
    'lib/features/home/presentation',
    'lib/features/home/presentation/tabs',
    'lib/features/profile/presentation',
    'lib/features/settings/presentation',
    'lib/shared/widgets',
    'lib/routes',
  ];

  // Define files to create with basic content
  final files = {
    'lib/core/network/dio_client.dart': '''import 'package:dio/dio.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors if needed
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;
}
''',
    'lib/core/theme/app_theme.dart': '''import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
''',
    'lib/features/auth/bloc/auth_bloc.dart':
        '''import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;

  SignupRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;

  AuthAuthenticated({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userId = await authRepository.login(event.email, event.password);
      emit(AuthAuthenticated(userId: userId));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userId = await authRepository.signup(event.email, event.password);
      emit(AuthAuthenticated(userId: userId));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
''',
    'lib/features/auth/data/auth_repository.dart': '''class AuthRepository {
  // TODO: Implement actual authentication logic
  
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulate login
    if (email.isNotEmpty && password.isNotEmpty) {
      return 'user_id_123';
    }
    throw Exception('Invalid credentials');
  }

  Future<String> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulate signup
    if (email.isNotEmpty && password.isNotEmpty) {
      return 'user_id_456';
    }
    throw Exception('Signup failed');
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Clear tokens, preferences, etc.
  }
}
''',
    'lib/features/auth/presentation/login_screen.dart':
        '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../shared/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Login',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                              LoginRequested(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text('Don\\'t have an account? Sign up'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
''',
    'lib/features/auth/presentation/signup_screen.dart':
        '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../shared/widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Sign Up',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                              SignupRequested(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
''',
    'lib/features/home/presentation/home_screen.dart':
        '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/explore_tab.dart';
import '../../profile/presentation/profile_tab.dart';
import '../../settings/presentation/settings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const ExploreTab(),
    const ProfileTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Explore';
      case 2:
        return 'Profile';
      case 3:
        return 'Settings';
      default:
        return 'Home';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
''',
    'lib/features/home/presentation/tabs/dashboard_tab.dart':
        '''import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _DashboardCard(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  subtitle: 'View stats',
                  color: Colors.blue,
                  onTap: () {},
                ),
                _DashboardCard(
                  icon: Icons.task,
                  title: 'Tasks',
                  subtitle: '12 pending',
                  color: Colors.orange,
                  onTap: () {},
                ),
                _DashboardCard(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: '5 new',
                  color: Colors.red,
                  onTap: () {},
                ),
                _DashboardCard(
                  icon: Icons.message,
                  title: 'Messages',
                  subtitle: '3 unread',
                  color: Colors.green,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''',
    'lib/features/home/presentation/tabs/explore_tab.dart':
        '''import 'package:flutter/material.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Explore',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _ExploreCard(
          title: 'Trending Topics',
          subtitle: 'See what\\'s popular today',
          icon: Icons.trending_up,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ExploreCard(
          title: 'Discover New',
          subtitle: 'Find something interesting',
          icon: Icons.stars,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ExploreCard(
          title: 'Categories',
          subtitle: 'Browse by category',
          icon: Icons.category,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ExploreCard(
          title: 'Recommended',
          subtitle: 'Based on your interests',
          icon: Icons.recommend,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
''',
    'lib/features/profile/presentation/profile_tab.dart':
        '''import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        const Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              SizedBox(height: 16),
              Text(
                'John Doe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'john.doe@example.com',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Divider(),
        _ProfileMenuItem(
          icon: Icons.edit,
          title: 'Edit Profile',
          onTap: () {},
        ),
        _ProfileMenuItem(
          icon: Icons.lock,
          title: 'Change Password',
          onTap: () {},
        ),
        _ProfileMenuItem(
          icon: Icons.notifications,
          title: 'Notifications',
          onTap: () {},
        ),
        _ProfileMenuItem(
          icon: Icons.privacy_tip,
          title: 'Privacy',
          onTap: () {},
        ),
        const Divider(),
        _ProfileMenuItem(
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () {},
        ),
        _ProfileMenuItem(
          icon: Icons.info,
          title: 'About',
          onTap: () {},
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
''',
    'lib/features/settings/presentation/settings_tab.dart':
        '''import 'package:flutter/material.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoPlayVideos = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'Preferences',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive push notifications'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode),
          title: const Text('Dark Mode'),
          subtitle: const Text('Use dark theme'),
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = value;
            });
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.play_circle),
          title: const Text('Auto-play Videos'),
          subtitle: const Text('Automatically play videos'),
          value: _autoPlayVideos,
          onChanged: (value) {
            setState(() {
              _autoPlayVideos = value;
            });
          },
        ),
        const SizedBox(height: 20),
        const Divider(),
        const Text(
          'App Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: const Text('English'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.storage),
          title: const Text('Storage'),
          subtitle: const Text('Manage app storage'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Security'),
          subtitle: const Text('App security settings'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const SizedBox(height: 20),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text(
            'Clear Cache',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () {
            _showClearCacheDialog();
          },
        ),
      ],
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the app cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
''',
    'lib/shared/widgets/primary_button.dart':
        '''import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(text),
      ),
    );
  }
}
''',
    'lib/routes/app_router.dart': '''import 'package:flutter/material.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/home/presentation/home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for \${settings.name}'),
            ),
          ),
        );
    }
  }
}
''',
    'lib/main.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: context.read<AuthRepository>(),
        ),
        child: MaterialApp(
          title: 'Flutter BLoC Starter',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: '/login',
          onGenerateRoute: AppRouter.generateRoute,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
''',
    'pubspec.yaml': '''name: flutter_bloc_starter
description: A Flutter BLoC starter template project.
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Networking
  dio: ^5.4.0
  
  # UI
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
''',
    'README.md': '''# Flutter BLoC Starter Template

A well-structured Flutter starter template using the BLoC (Business Logic Component) pattern.

## Features

- ✅ BLoC state management
- ✅ Feature-first folder structure
- ✅ Authentication flow (Login/Signup)
- ✅ Bottom Navigation Bar with 4 tabs
- ✅ Routing setup
- ✅ Theme configuration
- ✅ Dio network client
- ✅ Reusable widgets

## Bottom Navigation Tabs

The home screen includes a bottom navigation bar with:
1. **Dashboard** - Overview cards with quick actions
2. **Explore** - Discover new content
3. **Profile** - User profile management
4. **Settings** - App preferences and configuration

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/               # Core utilities, config, theme
├── features/           # Feature modules (auth, home, profile, settings)
│   ├── auth/          # Authentication
│   ├── home/          # Dashboard & Explore tabs
│   ├── profile/       # Profile tab
│   └── settings/      # Settings tab
├── shared/             # Shared widgets and utilities
├── routes/             # App routing
└── main.dart           # App entry point
```

## Dependencies

- `flutter_bloc` - State management
- `equatable` - Value equality
- `dio` - HTTP client

## Next Steps

- [ ] Add proper API endpoints
- [ ] Implement token storage
- [ ] Add error handling
- [ ] Write tests
- [ ] Add more features to each tab
- [ ] Implement actual settings functionality

---

Happy coding! 🚀
''',
  };

  try {
    // Create directories
    print('📁 Creating directories...');
    for (var dir in directories) {
      final directory = Directory(dir);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
        print('   ✓ Created: $dir');
      }
    }

    print('\n📄 Creating files...');
    // Create files with content
    for (var entry in files.entries) {
      final file = File(entry.key);
      file.writeAsStringSync(entry.value);
      print('   ✓ Created: ${entry.key}');
    }

    print('\n✅ Flutter BLoC Starter Template setup completed successfully!');
    print('\n📋 Next steps:');
    print('   1. Run: flutter pub get');
    print('   2. Run: flutter run');
    print('   3. Start building your app! 🚀\n');
  } catch (e) {
    print('❌ Error during setup: $e');
    exit(1);
  }
}
