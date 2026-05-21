import 'package:aitmatov_app/features/messenger/presentation/messenger_channel_chat_screen.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:go_router/go_router.dart';

import '../features/aitmatov/presentation/aitmatov_screen.dart';
import '../features/admin/presentation/admin_analytics_screen.dart';
import '../features/admin/presentation/admin_feedback_screen.dart';
import '../features/admin/presentation/admin_logs_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/courses/presentation/course_screen.dart';
import '../features/courses/presentation/courses_list_screen.dart';
import '../features/home/presentation/schedule_screen.dart';
import '../features/lessons/presentation/lesson_screen.dart';
import '../features/navigation/presentation/role_navigation_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/feedback_request_screen.dart';
import '../features/profile/presentation/student_grades_screen.dart';
import '../features/profile/presentation/user_surveys_screen.dart';
import '../features/profile/presentation/user_profile_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/subjects/presentation/subjects_screen.dart';
import '../features/messenger/presentation/messenger_groups_screen.dart';
import '../features/messenger/presentation/messenger_chat_screen.dart';
import '../features/messenger/presentation/group_members_screen.dart';
import '../features/messenger/presentation/channel_members_screen.dart';
import '../features/teacher/presentation/teacher_grades_screen.dart';

class AppRouter {
  static final router = GoRouter(
    navigatorKey: ChuckerFlutter.navigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
          path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(
          path: '/student',
          builder: (context, state) =>
              const RoleNavigationScreen(role: 'student')),
      GoRoute(
          path: '/teacher',
          builder: (context, state) =>
              const RoleNavigationScreen(role: 'teacher')),
      GoRoute(
          path: '/admin',
          builder: (context, state) =>
              const RoleNavigationScreen(role: 'admin')),
      GoRoute(path: '/home', redirect: (context, state) => '/student'),
      GoRoute(
          path: '/aitmatov',
          builder: (context, state) => const AitmatovScreen()),
      GoRoute(
        path: '/subjects/:slug',
        builder: (context, state) =>
            SubjectsScreen(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) {
          final aitmatovThemeId =
              int.tryParse(state.uri.queryParameters['aitmatov_theme'] ?? '');
          final subjectId =
              int.tryParse(state.uri.queryParameters['subject'] ?? '');
          final isAitmatov = state.uri.queryParameters['is_aitmatov'] == 'true';
          return CoursesListScreen(
            aitmatovThemeId: aitmatovThemeId,
            subjectId: subjectId,
            isAitmatov: isAitmatov ? true : null,
          );
        },
      ),
      GoRoute(
        path: '/courses/:courseId',
        builder: (context, state) => CourseScreen(
            courseId:
                int.tryParse(state.pathParameters['courseId'] ?? '') ?? 0),
      ),
      GoRoute(
        path: '/courses/:courseId/lessons/:lessonId',
        builder: (context, state) => LessonScreen(
          courseId: int.tryParse(state.pathParameters['courseId'] ?? '') ?? 0,
          lessonId: int.tryParse(state.pathParameters['lessonId'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
          path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(
          path: '/student/grades',
          builder: (context, state) => const StudentGradesScreen()),
      GoRoute(
          path: '/surveys',
          builder: (context, state) => const UserSurveysScreen()),
      GoRoute(
          path: '/feedback/request',
          builder: (context, state) => const FeedbackRequestScreen()),
      GoRoute(
          path: '/teacher/grades',
          builder: (context, state) => const TeacherGradesScreen()),
      GoRoute(
        path: '/users/:id/profile',
        builder: (context, state) => UserProfileScreen(
            userId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(
          path: '/schedule',
          builder: (context, state) => const ScheduleScreen()),
      GoRoute(
          path: '/admin/analytics',
          builder: (context, state) => const AdminAnalyticsScreen()),
      GoRoute(
          path: '/admin/feedback',
          builder: (context, state) => const AdminFeedbackScreen()),
      GoRoute(
          path: '/admin/logs',
          builder: (context, state) => const AdminLogsScreen()),
      GoRoute(
          path: '/messenger',
          builder: (context, state) => const MessengerGroupsScreen()),
      GoRoute(
        path: '/messenger/group/:groupId',
        builder: (context, state) =>
            MessengerChatScreen(groupId: state.pathParameters['groupId'] ?? ''),
      ),
      GoRoute(
        path: '/messenger/group/:groupId/members',
        builder: (context, state) => GroupMembersScreen(groupId: state.pathParameters['groupId'] ?? ''),
      ),
      GoRoute(
        path: '/messenger/channel/:channelId',
        builder: (context, state) => MessengerChannelChatScreen(
          channelId: state.pathParameters['channelId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/messenger/channel/:channelId/members',
        builder: (context, state) => ChannelMembersScreen(channelId: state.pathParameters['channelId'] ?? ''),
      ),
    ],
  );
}
