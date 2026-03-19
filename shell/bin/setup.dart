#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('package', abbr: 'p', help: 'Target specific package name')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage help');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printHelp(parser);
      return;
    }

    final packageName = results['package'] as String?;

    print('� Flutter Project Setup');
    print('=' * 50);

    final currentDir = Directory.current.path;
    final projectRoot = currentDir.endsWith('shell')
        ? Directory.current.parent.path
        : currentDir;

    print('📁 Project root: $projectRoot');
    if (packageName != null) {
      print('🎯 Target package: $packageName');
    }
    print('');

    if (packageName != null) {
      await _setupSinglePackage(projectRoot, packageName);
    } else {
      await _setupAllPackages(projectRoot);
    }

    print('\n' + '=' * 50);
    print('✅ Setup completed successfully!');
    print('=' * 50);
  } catch (e) {
    print('❌ Error: $e');
    print('\nUse --help to see usage information');
    exit(1);
  }
}

void _printHelp(ArgParser parser) {
  print('Flutter Project Setup Tool');
  print('');
  print('Usage: dart setup.dart [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  dart setup.dart                    # Setup all packages');
  print('  dart setup.dart -p reflection_data # Setup specific package');
  print('  dart setup.dart --package lt_app   # Setup specific app');
}

Future<void> _setupSinglePackage(String projectRoot, String packageName) async {
  final packagePath = await _findPackage(projectRoot, packageName);
  if (packagePath == null) {
    throw Exception('Package "$packageName" not found');
  }

  print('📦 Setting up $packageName...\n');
  await _runFlutterPubGet(packagePath, packageName);
}

Future<void> _setupAllPackages(String projectRoot) async {
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
}

Future<String?> _findPackage(String projectRoot, String packageName) async {
  final searchDirs = [
    path.join(projectRoot, 'packages', 'core', packageName),
    path.join(projectRoot, 'packages', 'domain', packageName),
    path.join(projectRoot, 'packages', 'data', packageName),
    path.join(projectRoot, 'packages', 'features', packageName),
    path.join(projectRoot, 'packages', 'utls', packageName),
    path.join(projectRoot, 'apps', packageName),
  ];

  for (final dir in searchDirs) {
    final pubspecFile = File(path.join(dir, 'pubspec.yaml'));
    if (await pubspecFile.exists()) {
      return dir;
    }
  }

  return null;
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
