import 'package:flutter_test/flutter_test.dart';
import 'package:prepsarthi/data/repositories/purchase_repository.dart';
import 'package:prepsarthi/domain/usecases/readiness_score.dart';

void main() {
  test('billing identifiers remain production values', () {
    expect(kSubscriptionProductId, 'prepsarthi_premium');
    expect(kBasePlanMonthly, 'monthly');
    expect(kBasePlanQuarterly, 'quarterly');
    expect(kBasePlanAnnual, 'annual');
    expect(kTrialOfferId, 'trial_7_days_new_user');
  });

  test('empty readiness exposes fallback advice', () {
    expect(ReadinessScore.empty.advice, isNotEmpty);
    expect(ReadinessScore.empty.tips, isNotEmpty);
  });
}
