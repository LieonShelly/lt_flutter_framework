#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  print('⚙️  Flutter Code Generation');
  print('=' * 50);

  final currentDir = Directory.current.path;
  final projectRoot = currentDir.endsWith('shell')
      ? Directory.current.parent.path
      : currentDir;

  print('📁 Project root: $projectRoot\n');

  final watch = arguments.contains('--watch') || arguments.contains('-w');
  final deleteConflicting = !arguments.contains('--no-delete-conflicting');

  if (watch) {
    print('👀 Running in watch mode...\n');
  }

  await _runCodeGeneration(projectRoot, watch, deleteConflicting);

  print('\n' + '=' * 50);
  print('✅ Code generation completed!');
  print('=' * 50);
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
