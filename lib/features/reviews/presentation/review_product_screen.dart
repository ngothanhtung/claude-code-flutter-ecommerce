import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/product_review.dart';
import 'review_providers.dart';

class ReviewScreenArgs {
  const ReviewScreenArgs({
    required this.productId,
    required this.productName,
    required this.orderId,
  });

  final String productId;
  final String productName;
  final String orderId;
}

class ReviewProductScreen extends ConsumerStatefulWidget {
  const ReviewProductScreen({super.key, required this.args});
  static const routeName = '/review-product';
  final ReviewScreenArgs args;

  @override
  ConsumerState<ReviewProductScreen> createState() =>
      _ReviewProductScreenState();
}

class _ReviewProductScreenState extends ConsumerState<ReviewProductScreen> {
  final comment = TextEditingController();
  int rating = 0;
  bool loading = true;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadReview);
  }

  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  Future<void> _loadReview() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) setState(() => loading = false);
      return;
    }
    try {
      final review = await ref
          .read(reviewRepositoryProvider)
          .findUserReview(productId: widget.args.productId, userId: user.id);
      if (!mounted) return;
      setState(() {
        rating = review?.rating ?? 0;
        comment.text = review?.comment ?? '';
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Unable to load your review. Please try again.';
      });
    }
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() => error = 'Please sign in before reviewing a product.');
      return;
    }
    final text = comment.text.trim();
    if (rating == 0) {
      setState(() => error = 'Choose a rating from 1 to 5 stars.');
      return;
    }
    if (text.length < 3) {
      setState(() => error = 'Tell us a little more about the product.');
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await ref
          .read(reviewRepositoryProvider)
          .saveReview(
            ProductReview(
              userId: user.id,
              userName: user.name,
              userEmail: user.email,
              productId: widget.args.productId,
              orderId: widget.args.orderId,
              rating: rating,
              comment: text,
            ),
          );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        saving = false;
        error = 'Unable to save your review. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Review product')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    widget.args.productName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'How was your experience with this product?',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    label: '$rating out of 5 stars selected',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var value = 1; value <= 5; value++)
                          IconButton(
                            key: ValueKey('review-star-$value'),
                            tooltip: '$value star${value == 1 ? '' : 's'}',
                            onPressed: saving
                                ? null
                                : () => setState(() {
                                    rating = value;
                                    error = null;
                                  }),
                            iconSize: 40,
                            color: colors.tertiary,
                            icon: Icon(
                              value <= rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    key: const ValueKey('review-comment-field'),
                    controller: comment,
                    enabled: !saving,
                    maxLength: 500,
                    minLines: 5,
                    maxLines: 8,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Your review',
                      hintText: 'What did you like? What could be better?',
                      alignLabelWithHint: true,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      key: const ValueKey('review-error'),
                      style: TextStyle(
                        color: colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    key: const ValueKey('submit-review-button'),
                    onPressed: saving ? null : _submit,
                    icon: saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.rate_review_outlined),
                    label: Text(saving ? 'Saving…' : 'Save review'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
