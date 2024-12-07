import 'package:flutter/material.dart';
import '../views/welcome_view.dart';
import '../views/home_view.dart';
import '../views/course_details_view.dart';
import '../views/student_list_view.dart';
import '../views/student_assessment_view.dart';
import '../views/login_view.dart';
import '../views/psychology_assessment_view.dart';
import '../views/community_nursing_assessment_view.dart';
import '../views/hospital_nursing_assessment_view.dart';
import '../controllers/auth_controller.dart';

class AppRoutes {
  static const String welcomeView = '/welcome';
  static const String loginView = '/login';
  static const String homeView = '/home';
  static const String courseDetailsView = '/course_details';
  static const String studentListView = '/student_list';
  static const String studentAssessmentView = '/student_assessment';
  static const String psychologyAssessmentView = '/psychology_assessment';
  static const String communityNursingAssessmentView = '/community_assessment';
  static const String hospitalNursingAssessmentView = '/hospital_assessment';

  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes {
    return {
      initialRoute: (context) => _handleAuthState(),
      welcomeView: (context) => const WelcomeView(),
      loginView: (context) => const LoginView(),
      homeView: (context) => const HomeView(),
      courseDetailsView: (context) => const CourseDetailsView(),
      studentListView: (context) => const StudentListView(),
      studentAssessmentView: (context) => const StudentAssessmentView(),
      psychologyAssessmentView: (context) => const PsychologyAssessmentView(),
      communityNursingAssessmentView: (context) => const CommunityNursingAssessmentView(),
      hospitalNursingAssessmentView: (context) => const HospitalNursingAssessmentView(),
    };
  }

  static Widget _handleAuthState() {
    return StreamBuilder<Widget>(
      stream: AuthController().handleAuthState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const WelcomeView(showContinueButton: false);
        }

        return snapshot.data ?? const WelcomeView(showContinueButton: true);
      },
    );
  }
}