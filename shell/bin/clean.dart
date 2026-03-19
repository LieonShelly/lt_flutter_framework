#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  print('🧹 Flutter Project Clean');
  print('=' * 50);

  final currentDir = Directory.current.path;
  final projectRoot = currentDir.endsWith('shell')
      ? Directory.current.parent.path
      : currentDir;

  print('📁 Project root: $projectRoot\n');

  final cleanSteps = [
    () => _cleanPackages(projectRoot),
    () => _cleanApps(projectRoot),
    () => _cleanRoot(projectRoot),
  ];

  var totalCleaned = 0;

  for (var step in cleanSteps) {
    totalCleaned += await step();
  }

  print('\n' + '=' * 50);
  print('✅ Cleaned $totalCleaned directories');
  print('=' * 50);
}

Future<int> _cleanPackages(String projectRoot) async {
  print('🧹 Cleaning package directories...');

  final packagesDir = Directory(path.join(projectRoot, 'packages'));
  if (!await packagesDir.exists()) {
    print('⚠️  packages directory not found, skipping');
    return 0;
  }

  var count = 0;
  final categories = ['core', 'domain', 'data', 'features', 'utls'];

  for (final category in categories) {
    final categoryDir = Directory(path.join(packagesDir.path, category));
    if (!await categoryDir.exists()) continue;

    await for (final entity in categoryDir.list()) {
      if (entity is Directory) {
        count += await _cleanDirectory(entity.path);
      }
    }
  }

  print('  ✓ Cleaned $count package directories\n');
  return count;
}

Future<int> _cleanApps(String projectRoot) async {
  print('🧹 Cleaning app directories...');

  final appsDir = Directory(path.join(projectRoot, 'apps'));
  if (!await appsDir.exists()) {
    print('⚠️  apps directory not found, skipping');
    return 0;
  }

  var count = 0;

  await for (final entity in appsDir.list()) {
    if (entity is Directory) {
      count += await _cleanDirectory(entity.path);
    }
  }

  print('  ✓ Cleaned $count app directories\n');
  return count;
}

Future<int> _cleanRoot(String projectRoot) async {
  print('🧹 Cleaning root directory...');

  final count = await _cleanDirectory(projectRoot);

  print('  ✓ Cleaned root directory\n');
  return count;
}

Future<int> _cleanDirectory(String directory) async {
  var count = 0;
  final dirsToClean = [
    '.dart_tool',
    'build',
    '.flutter-plugins',
    '.flutter-plugins-dependencies',
    'pubspec.lock',
  ];

  for (final dirName in dirsToClean) {
    final targetPath = path.join(directory, dirName);
    final target = FileSystemEntity.typeSync(targetPath);

    if (target == FileSystemEntityType.directory) {
      final dir = Directory(targetPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        count++;
        stdout.write(
          '    🗑️  Deleted: ${path.relative(targetPath, from: directory)}\n',
        );
      }
    } else if (target == FileSystemEntityType.file) {
      final file = File(targetPath);
      if (await file.exists()) {
        await file.delete();
        stdout.write(
          '    🗑️  Deleted: ${path.relative(targetPath, from: directory)}\n',
        );
      }
    }
  }

  return count;
}
