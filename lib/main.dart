import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'app/di/injection_container.dart';
import 'features/projects/data/adapters/project_adapter.dart';
import 'features/projects/domain/entities/project.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ProjectAdapter());
  }

  // Because the adapter had a read/write mismatch bug until now, any data
  // written by the old broken adapter is corrupt. Clear it out ONE TIME
  // on this run only, then never again — see note below.
  if (Hive.isBoxOpen(AppConstants.boxProjects)) {
    await Hive.box(AppConstants.boxProjects).close();
  }
  await Hive.deleteBoxFromDisk(AppConstants.boxProjects);

  final projectBox = await Hive.openBox<Project>(AppConstants.boxProjects);

  await initDependencies(projectBox);
  final subscriptionBox = await Hive.openBox(AppConstants.boxSubscription);
  await initDependencies(projectBox, subscriptionBox); // update signature

  runApp(const ClipCraftApp());
}
