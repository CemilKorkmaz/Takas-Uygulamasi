import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase yapılandırması için: `flutterfire configure` çalıştırın.
  // firebase_options.dart oluşturulduktan sonra uygulama Firebase'e bağlanır.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase henüz yapılandırılmadıysa uygulama yerel geliştirmede
    // yine de açılabilir; Firebase bağımlı özellikler yapılandırma
    // sonrası aktif olur.
  }

  await initializeDateFormatting('tr_TR', null);

  runApp(const ProviderScope(child: TakasApp()));
}
