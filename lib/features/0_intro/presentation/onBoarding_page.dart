import 'package:dokie/app/main_screen.dart';
import 'package:dokie/features/0_intro/data/datasources/onboarding_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnBoardingSlider(
      finishButtonText: 'Start Now',
      onFinish: () => _completeOnboarding(context),
      finishButtonStyle: const FinishButtonStyle(
        backgroundColor: Color(0xFF8B5CF6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
      skipTextButton: const Text(
        'Skip',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF8B5CF6),
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      trailingFunction: () => _completeOnboarding(context),
      controllerColor: const Color(0xFF8B5CF6),
      totalPage: 6,
      headerBackgroundColor: Colors.white,
      pageBackgroundColor: Colors.white,
      background: [
        // Background untuk slide 1
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Background untuk slide 2
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Background untuk slide 3
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
        // Background untuk slide 4
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9333EA), Color(0xFF8B5CF6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Background untuk slide 5
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Background untuk slide 6
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ],
      speed: 1.8,
      pageBodies: [
        OnboardingContent(
          imagePath: 'assets/images/doko.png',
          title: 'Greeting',
          description:
              'Welcome to our app, Doko the best task management app in Playstore.',
        ),
        OnboardingContent(
          imagePath: 'assets/images/1.png',
          title: 'Interactive Calendar For Task Management',
          description:
              'No task for today? No Worries Doko would solve that problem for you!',
        ),
        OnboardingContent(
          imagePath: 'assets/images/2.png',
          title: 'Create Your Group',
          description:
              'Hop onto your group tab and then click on the Create New Group button.',
        ),
        OnboardingContent(
          imagePath: 'assets/images/3.png',
          title: 'Group Flow',
          description:
              'Give your group a name as you wish and let the magic calculate your task progress.',
        ),
        OnboardingContent(
          imagePath: 'assets/images/4.png',
          title: 'Easy Task Making',
          description:
              'Just a few click! With Doko you can create your task and manage it easily.',
        ),
        OnboardingContent(
          imagePath: 'assets/images/5.png',
          title: 'Focus Mode',
          description:
              'No focus, its okay! We got you. With our new focus mode you could be more focus on your task.',
        ),
      ],
    );
  }
}
