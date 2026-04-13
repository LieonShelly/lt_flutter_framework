#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

const requiredFlutterVersion = '3.35.7';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('module', abbr: 'm', help: 'Flutter module name (under apps/)')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage help');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printHelp(parser);
      return;
    }

    final moduleName = results['module'] as String?;

    if (moduleName == null) {
      print('❌ 缺少 --module 参数\n');
      _printHelp(parser);
      exit(1);
    }

    print('🔨 Flutter Module XCFramework 构建');
    print('=' * 50);

    final currentDir = Directory.current.path;
    final projectRoot = currentDir.endsWith('shell')
        ? Directory.current.parent.path
        : currentDir;

    print('📁 Project root: $projectRoot');
    print('🎯 Target module: $moduleName');
    print('');

    final moduleDir = path.join(projectRoot, 'apps', moduleName);
    final outputDir = 'build/ios/xcframework';

    // Step 1: 模块验证
    await _validateModule(moduleDir, moduleName);

    // Step 2: 环境检查
    await _checkEnvironment();

    // Step 3: 依赖解析
    await _resolveDependencies(moduleDir);

    // Step 4: 构建 XCFramework
    await _buildXcframework(moduleDir, outputDir);

    // Step 5: 验证产物
    final releaseDir = path.join(moduleDir, outputDir, 'Release');
    await _verifyArtifacts(releaseDir);

    // 完成
    print('');
    print('✅ 🎉 $moduleName XCFramework 构建成功！');
    print('   产物目录: $releaseDir');
    print('   包含:');
    await _listArtifacts(releaseDir);

    print('\n' + '=' * 50);
    print('✅ Build completed successfully!');
    print('=' * 50);
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

void _printHelp(ArgParser parser) {
  print('Flutter Module XCFramework 构建工具');
  print('');
  print('Usage: dart build_xcframework.dart [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  dart build_xcframework.dart -m answer_detail_module');
  print('  dart build_xcframework.dart --module answer_detail_module');
}

Future<void> _validateModule(String moduleDir, String moduleName) async {
  print('🔍 验证模块 $moduleName...');

  final dir = Directory(moduleDir);
  if (!await dir.exists()) {
    throw Exception('模块目录不存在: apps/$moduleName/');
  }

  final pubspecFile = File(path.join(moduleDir, 'pubspec.yaml'));
  if (!await pubspecFile.exists()) {
    throw Exception('模块缺少 pubspec.yaml: apps/$moduleName/pubspec.yaml');
  }

  final content = await pubspecFile.readAsString();
  if (!content.contains('module:')) {
    throw Exception('该模块不是 Flutter Module（pubspec.yaml 中缺少 flutter.module 配置）');
  }

  print('  ✓ 模块验证通过\n');
}

Future<void> _checkEnvironment() async {
  print('🔍 检查构建环境...');

  // 检查 FVM
  final fvmResult = await Process.run('which', ['fvm']);
  if (fvmResult.exitCode != 0) {
    throw Exception('FVM 未安装。请先安装 FVM: dart pub global activate fvm');
  }

  // 检查 Flutter 版本
  final versionResult = await Process.run('fvm', ['list']);
  if (versionResult.exitCode != 0) {
    throw Exception('无法获取 FVM 版本列表');
  }

  final versionOutput = versionResult.stdout as String;
  final versionMatch = RegExp(r'3\.\d+\.\d+').firstMatch(versionOutput);
  final currentVersion = versionMatch?.group(0);

  if (currentVersion != requiredFlutterVersion) {
    throw Exception(
      'Flutter 版本不匹配。需要 $requiredFlutterVersion，当前为 $currentVersion\n'
      '请执行: fvm install $requiredFlutterVersion && fvm use $requiredFlutterVersion',
    );
  }

  print('  ✓ 环境检查通过 (Flutter $requiredFlutterVersion)\n');
}

Future<void> _resolveDependencies(String moduleDir) async {
  print('📦 解析依赖...');

  final result = await Process.run('fvm', [
    'flutter',
    'pub',
    'get',
  ], workingDirectory: moduleDir);

  if (result.exitCode != 0) {
    print('  ${result.stderr}');
    throw Exception('依赖解析失败 (flutter pub get)');
  }

  print('  ✓ 依赖解析完成\n');
}

Future<void> _buildXcframework(String moduleDir, String outputDir) async {
  print('🔨 构建 XCFramework (Release)...');

  final result = await Process.run('fvm', [
    'flutter',
    'build',
    'ios-framework',
    '--no-debug',
    '--no-profile',
    '--output=$outputDir',
  ], workingDirectory: moduleDir);

  if (result.exitCode != 0) {
    print('  ${result.stderr}');
    throw Exception('XCFramework 构建失败 (flutter build ios-framework)');
  }

  print('  ✓ XCFramework 构建完成\n');
}

Future<void> _verifyArtifacts(String releaseDir) async {
  print('🔎 验证构建产物...');

  final appXcframework = Directory(path.join(releaseDir, 'App.xcframework'));
  if (!await appXcframework.exists()) {
    throw Exception('缺少 App.xcframework');
  }

  final flutterXcframework = Directory(
    path.join(releaseDir, 'Flutter.xcframework'),
  );
  if (!await flutterXcframework.exists()) {
    throw Exception('缺少 Flutter.xcframework');
  }

  print('  ✓ 产物验证通过\n');
}

Future<void> _listArtifacts(String releaseDir) async {
  final dir = Directory(releaseDir);
  if (!await dir.exists()) return;

  await for (final entity in dir.list()) {
    final name = path.basename(entity.path);
    if (name.endsWith('.xcframework')) {
      print('     - $name');
    }
  }
}
