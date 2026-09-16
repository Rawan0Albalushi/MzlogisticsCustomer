import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';

final authenticatedMediaProvider =
    FutureProvider.autoDispose.family<Uint8List, String>((ref, path) {
  return ref.watch(apiClientProvider).getBytes(path);
});

class AuthenticatedImage extends ConsumerWidget {
  const AuthenticatedImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(authenticatedMediaProvider(path));
    return value.when(
      data: (bytes) => Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
      ),
      loading: () => SizedBox(
        width: width,
        height: height,
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, _) => Container(
        width: width,
        height: height,
        color: AppColors.surface,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, color: AppColors.muted),
      ),
    );
  }
}
