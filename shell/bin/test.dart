#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('package', abbr: 'p', help: 'Target specific package name')
    ..addFlag(
      'coverage',
      abbr: 'c',
      negatable: false,
      help: 'Collect coverage and generate report',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage help');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printHelp(parser);
      return;
    }

    final packageName = results['package'] as String?;
    final coverage = results['coverage'] as bool;

    print('🧪 Flutter Project Test');
    print('=' * 50);

    final currentDir = Directory.current.path;
    final projectRoot = currentDir.endsWith('shell')
        ? Directory.current.parent.path
        : currentDir;

    print('📁 Project root: $projectRoot');
    if (packageName != null) {
      print('🎯 Target package: $packageName');
    }
    if (coverage) {
      print('📊 Coverage collection enabled');
    }
    print('');

    if (packageName != null) {
      await _testSinglePackage(projectRoot, packageName, coverage);
    } else {
      await _testAllPackages(projectRoot, coverage);
    }

    print('\n' + '=' * 50);
    print('✅ Test completed!');
    print('=' * 50);
  } catch (e) {
    print('❌ Error: $e');
    print('\nUse --help to see usage information');
    exit(1);
  }
}

void _printHelp(ArgParser parser) {
  print('Flutter Project Test Tool');
  print('');
  print('Usage: dart test.dart [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  dart test.dart                              # Test all packages');
  print(
    '  dart test.dart -p reflection_domain          # Test specific package',
  );
  print('  dart test.dart -p reflection_domain -c       # Test with coverage');
  print(
    '  dart test.dart --coverage                    # Test all with coverage',
  );
}

Future<void> _testSinglePackage(
  String projectRoot,
  String packageName,
  bool coverage,
) async {
  final packagePath = await _findPackage(projectRoot, packageName);
  if (packagePath == null) {
    throw Exception('Package "$packageName" not found');
  }

  final testDir = Directory(path.join(packagePath, 'test'));
  if (!await testDir.exists()) {
    print('⚠️  No test directory found for "$packageName", skipping');
    return;
  }

  print('🧪 Running tests for $packageName...\n');
  final success = await _runTests(packagePath, packageName, coverage);

  if (coverage && success) {
    await _generateCoverageReport(packagePath, packageName);
  }
}

Future<void> _testAllPackages(String projectRoot, bool coverage) async {
  print('🧪 Discovering packages with tests...\n');

  final targetDirs = <_TestTarget>[];

  final packagesDir = Directory(path.join(projectRoot, 'packages'));
  if (await packagesDir.exists()) {
    final categories = ['core', 'domain', 'data', 'features', 'utls'];

    for (final category in categories) {
      final categoryDir = Directory(path.join(packagesDir.path, category));
      if (!await categoryDir.exists()) continue;

      await for (final entity in categoryDir.list()) {
        if (entity is Directory) {
          final testDir = Directory(path.join(entity.path, 'test'));
          if (await testDir.exists() && await _hasTestFiles(testDir)) {
            final displayName = path.relative(entity.path, from: projectRoot);
            targetDirs.add(_TestTarget(entity.path, displayName));
          }
        }
      }
    }
  }

  final appsDir = Directory(path.join(projectRoot, 'apps'));
  if (await appsDir.exists()) {
    await for (final entity in appsDir.list()) {
      if (entity is Directory) {
        final testDir = Directory(path.join(entity.path, 'test'));
        if (await testDir.exists() && await _hasTestFiles(testDir)) {
          final displayName = path.relative(entity.path, from: projectRoot);
          targetDirs.add(_TestTarget(entity.path, displayName));
        }
      }
    }
  }

  if (targetDirs.isEmpty) {
    print('⚠️  No packages with tests found');
    return;
  }

  print('Found ${targetDirs.length} packages with tests\n');

  var passed = 0;
  var failed = 0;

  for (final target in targetDirs) {
    final success = await _runTests(target.path, target.displayName, coverage);
    if (success) {
      passed++;
      if (coverage) {
        await _generateCoverageReport(target.path, target.displayName);
      }
    } else {
      failed++;
    }
  }

  print('');
  print(
    '📊 Results: $passed passed, $failed failed, '
    '${targetDirs.length} total',
  );

  if (failed > 0) {
    exit(1);
  }
}

Future<bool> _runTests(
  String directory,
  String displayName,
  bool coverage,
) async {
  print('  📦 $displayName');

  final isDartOnly = await _isDartOnlyPackage(directory);

  final List<String> args;
  if (isDartOnly) {
    args = ['dart', 'test'];
    if (coverage) args.add('--coverage=coverage');
  } else {
    args = ['flutter', 'test'];
    if (coverage) args.add('--coverage');
  }

  final result = await Process.run('fvm', args, workingDirectory: directory);

  if (result.exitCode == 0) {
    print('     ✓ All tests passed');
    if (coverage) print('     📊 Coverage data collected');
    print('');
    return true;
  } else {
    print('     ❌ Tests failed');
    final stderr = (result.stderr as String).trim();
    final stdout = (result.stdout as String).trim();
    if (stderr.isNotEmpty) print('     $stderr');
    if (stdout.isNotEmpty) {
      final lines = stdout.split('\n');
      final summaryLines = lines.length > 10
          ? lines.sublist(lines.length - 10)
          : lines;
      for (final line in summaryLines) {
        print('     $line');
      }
    }
    print('');
    return false;
  }
}

Future<void> _generateCoverageReport(
  String directory,
  String displayName,
) async {
  final lcovFile = File(path.join(directory, 'coverage', 'lcov.info'));

  // 纯 Dart 包的 dart test --coverage 生成 .vm.json 文件，
  // 需要用 format_coverage 转换为 lcov 格式
  if (!await lcovFile.exists()) {
    final coverageDir = Directory(path.join(directory, 'coverage'));
    if (!await coverageDir.exists()) {
      print('     ⚠️  No coverage data found');
      return;
    }

    print('     🔄 Converting coverage data to lcov format...');
    final formatResult = await Process.run('fvm', [
      'dart',
      'run',
      'coverage:format_coverage',
      '--lcov',
      '--in=${coverageDir.path}',
      '--out=${lcovFile.path}',
      '--report-on=lib/',
      '--package=$directory',
    ], workingDirectory: directory);

    if (formatResult.exitCode != 0) {
      print('     ⚠️  Failed to convert coverage data');
      final stderr = (formatResult.stderr as String).trim();
      if (stderr.isNotEmpty) print('        $stderr');
      return;
    }
  }

  if (!await lcovFile.exists()) {
    print('     ⚠️  No lcov.info generated');
    return;
  }

  // 打印文本覆盖率摘要
  await _printTextCoverageSummary(lcovFile);

  // 如果有 genhtml，生成 HTML 报告
  final whichResult = await Process.run('which', ['genhtml']);
  if (whichResult.exitCode == 0) {
    final htmlDir = path.join(directory, 'coverage', 'html');
    await Process.run('genhtml', [lcovFile.path, '-o', htmlDir, '--quiet']);
    print('     📄 HTML report: $htmlDir/index.html');
  } else {
    print('     💡 Install lcov for HTML reports: brew install lcov');
  }
}

Future<void> _printTextCoverageSummary(File lcovFile) async {
  final content = await lcovFile.readAsString();
  final lines = content.split('\n');

  var totalLines = 0;
  var hitLines = 0;

  for (final line in lines) {
    if (line.startsWith('LF:')) {
      totalLines += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      hitLines += int.parse(line.substring(3));
    }
  }

  if (totalLines > 0) {
    final percentage = (hitLines / totalLines * 100).toStringAsFixed(1);
    print('     � Coverage: $percentage% ($hitLines/$totalLines lines)');
  }
}

Future<bool> _isDartOnlyPackage(String directory) async {
  final pubspecFile = File(path.join(directory, 'pubspec.yaml'));
  if (!await pubspecFile.exists()) return true;
  final content = await pubspecFile.readAsString();
  return !content.contains('sdk: flutter');
}

Future<bool> _hasTestFiles(Directory testDir) async {
  await for (final entity in testDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('_test.dart')) {
      return true;
    }
  }
  return false;
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
    if (await pubspecFile.exists()) return dir;
  }

  return null;
}

class _TestTarget {
  final String path;
  final String displayName;
  const _TestTarget(this.path, this.displayName);
}
