#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  print('🚀 Flutter Project Setup');
  print('=' * 50);

  final currentDir = Directory.current.path;
  final projectRoot = currentDir.endsWith('shell')
      ? Directory.current.parent.path
      : currentDir;

  print('📁 Project root: $projectRoot\n');

  final setupSteps = [
    () => _setupFvm(projectRoot),
    () => _installRootDependencies(projectRoot),
    () => _installPackageDependencies(projectRoot),
    () => _installAppDependencies(projectRoot),
  ];

  for (var i = 0; i < setupSteps.length; i++) {
    try {
      await setupSteps[i]();
    } catch (e) {
      print('❌ Error at step ${i + 1}: $e');
      exit(1);
    }
  }

  print('\n' + '=' * 50);
  print('✅ Setup completed successfully!');
  print('=' * 50);
}

Future<void> _setupFvm(String projectRoot) async {
  print('📦 Step 1: Setting up FVM...');

  final fvmConfigFile = File(path.join(projectRoot, '.fvmrc'));
  if (!await fvmConfigFile.exists()) {
    print('⚠️  .fvmrc not found, skipping FVM setup');
    return;
  }

  final result = await Process.run('fvm', [
    'use',
    '3.35.7',
    '--force',
  ], workingDirectory: projectRoot);

  if (result.exitCode == 0) {
    print('✓ FVM configured: Flutter 3.35.7');
    print(result.stdout);
  } else {
    print('⚠️  FVM setup warning:');
    print(result.stderr);
  }
  print('');
}

Future<void> _installRootDependencies(String projectRoot) async {
  print('📦 Step 2: Installing root dependencies...');

  final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
  if (await pubspecFile.exists()) {
    await _runFlutterPubGet(projectRoot, 'root');
  } else {
    print('⚠️  No root pubspec.yaml found, skipping');
  }
  print('');
}

Future<void> _installPackageDependencies(String projectRoot) async {
  print('📦 Step 3: Installing package dependencies...');

  final packagesDir = Directory(path.join(projectRoot, 'packages'));
  if (!await packagesDir.exists()) {
    print('⚠️  packages directory not found, skipping');
    return;
  }

  final categories = ['core', 'domain', 'data', 'features', 'utls'];

  for (final category in categories) {
    final categoryDir = Directory(path.join(packagesDir.path, category));
    if (!await categoryDir.exists()) continue;

    print('  📂 Processing $category packages...');

    await for (final entity in categoryDir.list()) {
      if (entity is Directory) {
        final packageName = path.basename(entity.path);
        final pubspecFile = File(path.join(entity.path, 'pubspec.yaml'));

        if (await pubspecFile.exists()) {
          await _runFlutterPubGet(
            entity.path,
            'packages/$category/$packageName',
          );
        }
      }
    }
  }
  print('');
}

Future<void> _installAppDependencies(String projectRoot) async {
  print('📦 Step 4: Installing app dependencies...');

  final appsDir = Directory(path.join(projectRoot, 'apps'));
  if (!await appsDir.exists()) {
    print('⚠️  apps directory not found, skipping');
    return;
  }

  await for (final entity in appsDir.list()) {
    if (entity is Directory) {
      final appName = path.basename(entity.path);
      final pubspecFile = File(path.join(entity.path, 'pubspec.yaml'));

      if (await pubspecFile.exists()) {
        await _runFlutterPubGet(entity.path, 'apps/$appName');
      }
    }
  }
  print('');
}

Future<void> _runFlutterPubGet(String directory, String displayName) async {
  stdout.write('    ⏳ $displayName... ');

  final result = await Process.run('fvm', [
    'flutter',
    'pub',
    'get',
  ], workingDirectory: directory);

  if (result.exitCode == 0) {
    print('✓');
  } else {
    print('❌');
    print('       Error: ${result.stderr}');
    throw Exception('Failed to run pub get for $displayName');
  }
}
