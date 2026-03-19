#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('package', abbr: 'p', help: 'Target specific package name')
    ..addFlag('watch', abbr: 'w', negatable: false, help: 'Run in watch mode')
    ..addFlag(
      'delete-conflicting',
      defaultsTo: true,
      help: 'Delete conflicting outputs',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage help');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printHelp(parser);
      return;
    }

    final packageName = results['package'] as String?;
    final watch = results['watch'] as bool;
    final deleteConflicting = results['delete-conflicting'] as bool;

    print('⚙️  Flutter Code Generation');
    print('=' * 50);

    final currentDir = Directory.current.path;
    final projectRoot = currentDir.endsWith('shell')
        ? Directory.current.parent.path
        : currentDir;

    print('📁 Project root: $projectRoot');
    if (packageName != null) {
      print('🎯 Target package: $packageName');
    }
    if (watch) {
      print('👀 Running in watch mode');
    }
    print('');

    if (packageName != null) {
      await _runCodeGenerationForPackage(
        projectRoot,
        packageName,
        watch,
        deleteConflicting,
      );
    } else {
      await _runCodeGeneration(projectRoot, watch, deleteConflicting);
    }

    print('\n' + '=' * 50);
    print('✅ Code generation completed!');
    print('=' * 50);
  } catch (e) {
    print('❌ Error: $e');
    print('\nUse --help to see usage information');
    exit(1);
  }
}

void _printHelp(ArgParser parser) {
  print('Flutter Code Generation Tool');
  print('');
  print('Usage: dart codegen.dart [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  dart codegen.dart                    # Generate for all packages');
  print('  dart codegen.dart -w                 # Watch mode for all packages');
  print(
    '  dart codegen.dart -p reflection_data # Generate for specific package',
  );
  print(
    '  dart codegen.dart -p lt_app -w       # Watch mode for specific package',
  );
}

Future<void> _runCodeGenerationForPackage(
  String projectRoot,
  String packageName,
  bool watch,
  bool deleteConflicting,
) async {
  final packagePath = await _findPackage(projectRoot, packageName);
  if (packagePath == null) {
    throw Exception('Package "$packageName" not found');
  }

  final pubspecFile = File(path.join(packagePath, 'pubspec.yaml'));
  final content = await pubspecFile.readAsString();

  if (!content.contains('build_runner')) {
    throw Exception('Package "$packageName" does not have build_runner');
  }

  print('⚙️  Running build_runner for $packageName...\n');
  await _runBuildRunner(packagePath, packageName, watch, deleteConflicting);
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

Future<void> _runCodeGeneration(
  String projectRoot,
  bool watch,
  bool deleteConflicting,
) async {
  print('⚙️  Running build_runner...\n');

  final packagesDir = Directory(path.join(projectRoot, 'packages'));
  final appsDir = Directory(path.join(projectRoot, 'apps'));

  final targetDirs = <String>[];

  if (await packagesDir.exists()) {
    final categories = ['data', 'features'];

    for (final category in categories) {
      final categoryDir = Directory(path.join(packagesDir.path, category));
      if (!await categoryDir.exists()) continue;

      await for (final entity in categoryDir.list()) {
        if (entity is Directory) {
          final pubspecFile = File(path.join(entity.path, 'pubspec.yaml'));
          if (await pubspecFile.exists()) {
            final content = await pubspecFile.readAsString();
            if (content.contains('build_runner')) {
              targetDirs.add(entity.path);
            }
          }
        }
      }
    }
  }

  if (await appsDir.exists()) {
    await for (final entity in appsDir.list()) {
      if (entity is Directory) {
        final pubspecFile = File(path.join(entity.path, 'pubspec.yaml'));
        if (await pubspecFile.exists()) {
          final content = await pubspecFile.readAsString();
          if (content.contains('build_runner')) {
            targetDirs.add(entity.path);
          }
        }
      }
    }
  }

  print('Found ${targetDirs.length} packages with build_runner\n');

  for (final dir in targetDirs) {
    final displayName = path.relative(dir, from: projectRoot);
    await _runBuildRunner(dir, displayName, watch, deleteConflicting);
  }
}

Future<void> _runBuildRunner(
  String directory,
  String displayName,
  bool watch,
  bool deleteConflicting,
) async {
  print('  📦 $displayName');

  final args = ['run', 'build_runner'];

  if (watch) {
    args.add('watch');
  } else {
    args.add('build');
  }

  if (deleteConflicting) {
    args.add('--delete-conflicting-outputs');
  }

  final result = await Process.run('dart', args, workingDirectory: directory);

  if (result.exitCode == 0) {
    print('     ✓ Success\n');
  } else {
    print('     ❌ Failed');
    print('     ${result.stderr}\n');
  }
}
