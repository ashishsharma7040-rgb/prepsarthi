// lib/presentation/screens/settings/premium_paywall_screen.dart
//
// ✅ FIXED: Queries kSubscriptionProductId ('prepsarthi_premium') — NOT fake
//           composite IDs like 'prepsarthi_premium:monthly'.
// ✅ FIXED: On Android, uses GooglePlayProductDetails to extract basePlanId,
//           offerId, and offerIdToken — then purchases with GooglePlayPurchaseParam.
// ✅ FIXED: Trial offer purchased via offerIdToken for basePlanId+trialOfferId.
//           Non-trial purchase uses the base plan's default offer token.
// ✅ FIXED: markTrialStarted() → markTrialStartedLocally() (no client write to subscriptions).
// ✅ FIXED: markTrialStartedLocally() NOT called before purchase succeeds — only in app.dart.
// ✅ FIXED: offerToken → offerIdToken (correct SubscriptionOfferDetailsWrapper property).
// ✅ No purchaseStream listener here — owned by app.dart.

import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/purchase_repository.dart';
import '../../providers/all_providers.dart';
import '../../../router/app_router.dart';

// ── Plan display config ───────────────────────────────────────────────────────
// These are BASE PLAN IDs as defined in Play Console under subscription 'prepsarthi_premium'.

@immutable
class _PlanConfig {
  final String basePlanId;   // 'monthly' | 'quarterly' | 'annual'
  final String label;
  final String? badgeText;
  final String fallbackPrice;
  final String trialLine;
  final String noTrialLine;

  const _PlanConfig({
    required this.basePlanId,
    required this.label,
    required this.badgeText,
    required this.fallbackPrice,
    required this.trialLine,
    required this.noTrialLine,
  });
}

const _plans = [
  _PlanConfig(
    basePlanId:    kBasePlanMonthly,
    label:         'Monthly',
    badgeText:     null,
    fallbackPrice: '₹99/month',
    trialLine:     '7 days free, then ₹99/month',
    noTrialLine:   '₹99/month',
  ),
  _PlanConfig(
    basePlanId:    kBasePlanQuarterly,
    label:         'Quarterly',
    badgeText:     'SAVE 20%',
    fallbackPrice: '₹239/3 months',
    trialLine:     '7 days free, then ₹239/quarter',
    noTrialLine:   '₹239 per quarter',
  ),
  _PlanConfig(
    basePlanId:    kBasePlanAnnual,
    label:         'Annual',
    badgeText:     'BEST VALUE',
    fallbackPrice: '₹799/year',
    trialLine:     '7 days free, then ₹799/year',
    noTrialLine:   '₹799/year',
  ),
];

// ── State ─────────────────────────────────────────────────────────────────────

class PremiumPaywallScreen extends ConsumerStatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  ConsumerState<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen> {
  final _iap = InAppPurchase.instance;

  bool _loading    = true;
  bool _purchasing = false;
  bool _iapAvailable = false;
  String? _error;

  // Indexed by basePlanId → best matching GooglePlayProductDetails
  final Map<String, GooglePlayProductDetails> _androidPlans = {};
  // Fallback for non-Android
  final Map<String, ProductDetails> _genericProducts = {};

  String _selectedBasePlanId = kBasePlanMonthly;

  @override
  void initState() {
    super.initState();
    _initBilling();
  }

  // ── Billing initialisation ────────────────────────────────────────────────

  Future<void> _initBilling() async {
    try {
      _iapAvailable = await _iap.isAvailable();
      if (!_iapAvailable) return;

      // ✅ Query the single subscription product ID (not fake composites)
      final resp = await _iap.queryProductDetails(kAllProductIds);

      if (Platform.isAndroid) {
        // On Android each base plan / offer comes back as a separate
        // GooglePlayProductDetails with a basePlanId field.
        for (final pd in resp.productDetails) {
          if (pd is GooglePlayProductDetails) {
            final bpId = pd.productDetails.subscriptionOfferDetails
                    ?.firstOrNull?.basePlanId ??
                '';
            // Only store one entry per basePlanId; prefer trial offer entry
            final isTrialOffer = pd.productDetails.subscriptionOfferDetails
                    ?.any((o) => o.offerId == kTrialOfferId) ??
                false;
            if (!_androidPlans.containsKey(bpId) || isTrialOffer) {
              _androidPlans[bpId] = pd;
            }
          }
        }
      } else {
        // iOS / other: use generic ProductDetails (future-proofing)
        for (final pd in resp.productDetails) {
          _genericProducts[pd.id] = pd;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    // ✅ NO purchaseStream listener — handled centrally in app.dart
  }

  // ── Purchase ──────────────────────────────────────────────────────────────

  Future<void> _startPurchase(String basePlanId) async {
    if (!_iapAvailable) { _showBillingUnavailable(); return; }

    setState(() { _purchasing = true; _error = null; });

    try {
      final user           = ref.read(authProvider).user;
      final isTrialEligible = user?.isTrialEligible ?? true;

      if (Platform.isAndroid) {
        await _purchaseAndroid(basePlanId, isTrialEligible);
      } else {
        await _purchaseGeneric(basePlanId);
      }

      if (mounted) {
        setState(() => _purchasing = false);
        _showPurchasePending();
      }
    } catch (e) {
      if (mounted) setState(() { _purchasing = false; _error = e.toString(); });
    }
  }

  Future<void> _purchaseAndroid(String basePlanId, bool isTrialEligible) async {
    final gpd = _androidPlans[basePlanId];
    if (gpd == null) {
      setState(() => _error = 'Plan not available. Please try again later.');
      setState(() => _purchasing = false);
      return;
    }

    // Find the correct offer token:
    // - Trial-eligible user → pick offer with offerId == kTrialOfferId
    // - Otherwise          → pick the base plan offer (offerId == null / empty)
    final offerDetails =
        gpd.productDetails.subscriptionOfferDetails ?? [];

    SubscriptionOfferDetailsWrapper? targetOffer;
    if (isTrialEligible) {
      targetOffer = offerDetails
          .where((o) => o.offerId == kTrialOfferId)
          .firstOrNull;
    }
    // Fallback: use first offer for this base plan (no trial)
    targetOffer ??= offerDetails
        .where((o) => o.basePlanId == basePlanId)
        .firstOrNull;
    targetOffer ??= offerDetails.firstOrNull;

    if (targetOffer == null) {
      setState(() {
        _error = 'No valid offer found for $basePlanId. '
            'Please ensure Google Play subscription is set up correctly.';
        _purchasing = false;
      });
      return;
    }

    // ✅ Use GooglePlayPurchaseParam with offerIdToken for correct offer/trial
    // offerIdToken is the correct property on SubscriptionOfferDetailsWrapper
    final purchaseParam = GooglePlayPurchaseParam(
      productDetails: gpd,
      offerToken:     targetOffer.offerIdToken,
    );

    // ✅ Do NOT mark trial locally here — only mark after purchase succeeds in app.dart.
    // Marking before buyNonConsumable() can falsely set trialUsed=true if user cancels payment.

    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    // Result handled in app.dart _onPurchaseUpdate
  }

  Future<void> _purchaseGeneric(String basePlanId) async {
    final pd = _genericProducts[kSubscriptionProductId] ??
        _genericProducts.values.firstOrNull;
    if (pd == null) {
      setState(() {
        _error = 'Product not available. Please try again.';
        _purchasing = false;
      });
      return;
    }
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: pd));
  }

  Future<void> _restorePurchases() async {
    if (!_iapAvailable) { _showBillingUnavailable(); return; }
    setState(() => _purchasing = true);
    try {
      await _iap.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Checking for existing subscriptions…'),
        ));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _priceFor(String basePlanId) {
    if (Platform.isAndroid) {
      final gpd = _androidPlans[basePlanId];
      if (gpd != null) {
        final offer = gpd.productDetails.subscriptionOfferDetails
                ?.where((o) => o.basePlanId == basePlanId)
                .firstOrNull;
        if (offer != null && offer.pricingPhases.isNotEmpty) {
          return offer.pricingPhases.last.formattedPrice;
        }
      }
    }
    return kBasePlanFallbackPrices[basePlanId] ?? '';
  }

  void _showPurchasePending() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⏳ Processing Purchase'),
        content: const Text(
          'Your payment is being processed. Premium features will activate '
          'once payment is confirmed (usually within 1–2 minutes).\n\n'
          'If premium doesn\'t activate, tap Restore Purchases.',
        ),
        actions: [TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        )],
      ),
    );
  }

  void _showBillingUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Google Play Billing not available. Please use the Play Store version.'),
      duration: Duration(seconds: 4),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final subscription    = ref.watch(subscriptionProvider);
    final auth            = ref.watch(authProvider);
    final theme           = Theme.of(context);
    final isDark          = theme.brightness == Brightness.dark;
    final isTrialEligible = auth.user?.isTrialEligible ?? true;

    if (subscription.isPremium) {
      return _AlreadyPremiumScreen(subscription: subscription);
    }

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : const Color(0xFFF7F9FC),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _PaywallHero(isTrialEligible: isTrialEligible),
                      const SizedBox(height: 28),
                      _BenefitsList(isDark: isDark),
                      const SizedBox(height: 24),
                      _PlanSelector(
                        plans:           _plans,
                        selectedId:      _selectedBasePlanId,
                        isTrialEligible: isTrialEligible,
                        priceFor:        _priceFor,
                        onSelect:        (id) => setState(() => _selectedBasePlanId = id),
                        isDark:          isDark,
                      ),
                      const SizedBox(height: 20),

                      if (_purchasing)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        _CTAButton(
                          isTrialEligible: isTrialEligible,
                          iapAvailable:    _iapAvailable,
                          onTap:           () => _startPurchase(_selectedBasePlanId),
                        ),
                        const SizedBox(height: 12),
                        Center(child: TextButton(
                          onPressed: _restorePurchases,
                          child: const Text('Restore Purchase',
                              style: TextStyle(fontSize: 13)),
                        )),
                        Center(child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Continue with free plan',
                              style: TextStyle(fontSize: 13,
                                  color: Colors.grey.shade500)),
                        )),
                      ],

                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: LightColors.error, fontSize: 12),
                              textAlign: TextAlign.center),
                        ),

                      if (!_iapAvailable)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: LightColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '⚠️ Google Play Billing is not available on this device.',
                            style: TextStyle(fontSize: 12, color: LightColors.error),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 20),
                      _ComplianceText(
                        selectedBasePlanId: _selectedBasePlanId,
                        isTrialEligible:    isTrialEligible,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _PaywallHero extends StatelessWidget {
  final bool isTrialEligible;
  const _PaywallHero({required this.isTrialEligible});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      const Text('👑', style: TextStyle(fontSize: 52)),
      const SizedBox(height: 12),
      Text('Study Smarter for\nJEE, NEET & Class 12',
          style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900, height: 1.2),
          textAlign: TextAlign.center),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [LightColors.primary, Color(0xFF4CAF50)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isTrialEligible ? 'Start 7-Day Free Trial' : 'Unlock PrepSarthi Pro',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    ]).animate().fadeIn().slideY(begin: 0.08);
  }
}

const _benefits = [
  ('🧠', 'AI SWOT Analysis & Weak Area Detection'),
  ('📊', 'Mock Test Analytics & Accuracy Trends'),
  ('🎯', 'Exam Readiness Score (0–100)'),
  ('📋', 'Smart Backlog Recovery Engine'),
  ('📓', 'Mistake Notebook with Concept Linking'),
  ('🔄', 'Unlimited Spaced Revision Scheduling'),
  ('📄', 'PDF Progress Reports for Parents'),
  ('⚡', 'AI Study Plan Regeneration'),
  ('🏹', 'PYQ Tracker & 5-Level Chapter Mastery'),
  ('🔥', '90/60/30 Day Exam Countdown Mode'),
];

class _BenefitsList extends StatelessWidget {
  final bool isDark;
  const _BenefitsList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Everything in PrepSarthi Pro',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ..._benefits.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Text(e.value.$1, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Expanded(child: Text(e.value.$2,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500))),
            ]).animate().fadeIn(delay: (e.key * 30).ms),
          )),
        ],
      ),
    );
  }
}

class _PlanSelector extends StatelessWidget {
  final List<_PlanConfig> plans;
  final String selectedId;
  final bool isTrialEligible;
  final String Function(String basePlanId) priceFor;
  final ValueChanged<String> onSelect;
  final bool isDark;

  const _PlanSelector({
    required this.plans, required this.selectedId,
    required this.isTrialEligible, required this.priceFor,
    required this.onSelect, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose a Plan',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...plans.map((plan) {
          final selected  = plan.basePlanId == selectedId;
          final priceStr  = priceFor(plan.basePlanId);
          final subLine   = isTrialEligible ? plan.trialLine : plan.noTrialLine;

          return GestureDetector(
            onTap: () => onSelect(plan.basePlanId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected
                    ? LightColors.primary.withOpacity(0.08)
                    : (isDark ? DarkColors.surface : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? LightColors.primary : Colors.grey.shade200,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? LightColors.primary
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(child: Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(
                              color: LightColors.primary,
                              shape: BoxShape.circle)))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(plan.label,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      if (plan.badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: plan.badgeText == 'BEST VALUE'
                                ? LightColors.learned
                                : LightColors.tested,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(plan.badgeText!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 2),
                    Text(subLine,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: selected ? LightColors.primary : null,
                        )),
                  ],
                )),
                Text(priceStr,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected ? LightColors.primary : null,
                    )),
              ]),
            ),
          );
        }),
      ],
    );
  }
}

class _CTAButton extends StatelessWidget {
  final bool isTrialEligible;
  final bool iapAvailable;
  final VoidCallback onTap;
  const _CTAButton(
      {required this.isTrialEligible,
      required this.iapAvailable,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label =
        isTrialEligible ? 'Start 7-Day Free Trial' : 'Subscribe Now';
    return SizedBox(
      width: double.infinity, height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [LightColors.primary, Color(0xFF4CAF50)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: LightColors.primary.withOpacity(0.3),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: TextButton(
          onPressed: iapAvailable ? onTap : null,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16)),
        ),
      ),
    );
  }
}

class _ComplianceText extends StatelessWidget {
  final String selectedBasePlanId;
  final bool isTrialEligible;
  const _ComplianceText(
      {required this.selectedBasePlanId, required this.isTrialEligible});

  String get _priceLine {
    switch (selectedBasePlanId) {
      case kBasePlanQuarterly:
        return isTrialEligible
            ? '7 days free, then ₹239 per quarter.'
            : '₹239 per quarter.';
      case kBasePlanAnnual:
        return isTrialEligible
            ? '7 days free, then ₹799 per year.'
            : '₹799 per year.';
      default:
        return isTrialEligible
            ? '7 days free, then ₹99 per month.'
            : '₹99 per month.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        '$_priceLine Auto-renews unless cancelled at least 24 hours before renewal. '
        'Cancel anytime via Google Play → Subscriptions.',
        style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.6),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        children: [
          GestureDetector(
            // ✅ PRODUCTION FIX (v6): Try external URL; if not launchable
            //    (not yet hosted), fall back to the in-app PrivacyPolicyScreen.
            onTap: () async {
              final uri = Uri.parse('https://prepsarthi.app/privacy');
              if (!await launchUrl(uri,
                  mode: LaunchMode.externalApplication)) {
                if (context.mounted) context.push(AppRoutes.privacyPolicy);
              }
            },
            child: const Text('Privacy Policy',
                style: TextStyle(
                    fontSize: 11,
                    color: LightColors.primary,
                    decoration: TextDecoration.underline)),
          ),
          GestureDetector(
            // ✅ PRODUCTION FIX (v6): Try external URL; if not launchable
            //    fall back to the in-app TermsOfServiceScreen.
            onTap: () async {
              final uri = Uri.parse('https://prepsarthi.app/terms');
              if (!await launchUrl(uri,
                  mode: LaunchMode.externalApplication)) {
                if (context.mounted) context.push(AppRoutes.termsOfService);
              }
            },
            child: const Text('Terms of Use',
                style: TextStyle(
                    fontSize: 11,
                    color: LightColors.primary,
                    decoration: TextDecoration.underline)),
          ),
          GestureDetector(
            onTap: () => launchUrl(
                Uri.parse(
                    'https://play.google.com/store/account/subscriptions'),
                mode: LaunchMode.externalApplication),
            child: const Text('Manage Subscription',
                style: TextStyle(
                    fontSize: 11,
                    color: LightColors.primary,
                    decoration: TextDecoration.underline)),
          ),
        ],
      ),
    ]);
  }
}

class _AlreadyPremiumScreen extends StatelessWidget {
  final SubscriptionState subscription;
  const _AlreadyPremiumScreen({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('PrepSarthi Pro')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text("You're on PrepSarthi Pro!",
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(
                subscription.expiryDate != null
                    ? 'Active until ${subscription.expiryDate!.day}/'
                        '${subscription.expiryDate!.month}/'
                        '${subscription.expiryDate!.year}'
                    : 'All premium features unlocked',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(
                    'https://play.google.com/store/account/subscriptions')),
                icon: const Icon(Icons.subscriptions_outlined),
                label: const Text('Manage on Google Play'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
