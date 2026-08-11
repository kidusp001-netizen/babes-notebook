import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/onboarding_service.dart';

final onboardingCompleteProvider =
    AsyncNotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

class OnboardingNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => OnboardingService.instance.isComplete();

  Future<void> complete() async {
    await OnboardingService.instance.markComplete();
    state = const AsyncData(true);
  }

  Future<void> reset() async {
    await OnboardingService.instance.reset();
    state = const AsyncData(false);
  }
}
