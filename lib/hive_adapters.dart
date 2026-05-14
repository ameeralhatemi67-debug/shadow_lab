// lib/hive_adapters.dart
import 'package:hive_ce/hive_ce.dart';
import 'package:shadow_app/models/shadow_pair.dart';

// This tells hive_ce exactly what classes need database adapters
@GenerateAdapters([AdapterSpec<ShadowSettings>(), AdapterSpec<ShadowPair>()])
part 'hive_adapters.g.dart';
