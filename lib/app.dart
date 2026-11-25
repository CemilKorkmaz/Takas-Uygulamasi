import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

class TakasApp extends ConsumerWidget {
  const TakasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return CupertinoApp.router(
      title: 'Takas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertinoTheme,
      routerConfig: router,
      locale: const Locale('tr', 'TR'),
    );
  }
}
