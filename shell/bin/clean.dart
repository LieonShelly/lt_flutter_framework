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

    print('🧹 Flutter Project Clean');
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

    var totalCleaned = 0;

    if (packageName != null) {
      totalCleaned = await _cleanSinglePackage(projectRoot, packageName);
    } else {
      totalCleaned = await _cleanAllPackages(projectRoot);
    }

    print('\n' + '=' * 50);
    print('✅ Cleaned $totalCleaned directories');
    print('=' * 50);
  } catch (e) {
    print('❌ Error: $e');
    print('\nUse --help to see usage information');
    exit(1);
  }
}

void _printHelp(ArgParser parser) {
  print('Flutter Project Clean Tool');
  print('');
  print('Usage: dart clean.dart [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  dart clean.dart                    # Clean all packages');
  print('  dart clean.dart -p reflection_data # Clean specific package');
  print('  dart clean.dart --package lt_app   # Clean specific app');
}

Future<int> _cleanSinglePackage(String projectRoot, String packageName) async {
  final packagePath = await _findPackage(projectRoot, packageName);
  if (packagePath == null) {
    throw Exception('Package "$packageName" not found');
  }

  print('🧹 Cleaning $packageName...\n');
  return await _cleanDirectory(packagePath);
}

Future<int> _cleanAllPackages(String projectRoot) async {
  final cleanSteps = [
    () => _cleanPackages(projectRoot),
    () => _cleanApps(projectRoot),
    () => _cleanRoot(projectRoot),
  ];

  var totalCleaned = 0;

  for (var step in cleanSteps) {
    totalCleaned += await step();
  }

  return totalCleaned;
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
  // Skip cleaning shell directory to preserve script dependencies
  if (directory.endsWith('shell')) {
    return 0;
  }

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
