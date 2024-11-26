import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/welcome_view.dart';
import '../views/home_view.dart';
import '../views/course_details_view.dart';
import '../views/student_list_view.dart';
import '../views/student_assessment_view.dart';
import '../views/login_view.dart';
import '../views/psychology_assessment_view.dart';
import '../views/community_nursing_assessment_view.dart';
import '../views/hospital_nursing_assessment_view.dart';

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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Si está cargando, mostrar loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si hay usuario autenticado
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              // Si está cargando los datos de Firestore
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Si existe el documento y es profesor
              if (userSnapshot.hasData &&
                  userSnapshot.data!.exists &&
                  (userSnapshot.data!.data() as Map<String, dynamic>)['rol'] == 'profesor') {
                return const StudentListView();
              }

              // Si no existe documento o no es profesor (admin)
              return const HomeView();
            },
          );
        }

        // Si no hay usuario autenticado
        return const WelcomeView();
      },
    );
  }
}