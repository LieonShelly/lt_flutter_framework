#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('apple-id', abbr: 'u', help: 'Apple ID for App Store Connect')
    ..addOption(
      'password',
      abbr: 'p',
      help: 'App-specific password for Apple ID',
    )
    ..addOption('api-key', help: 'App Store Connect API Key ID')
    ..addOption('api-issuer', help: 'App Store Connect API Issuer ID')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage help');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printHelp(parser);
      return;
    }

    print('🚀 Starting iOS CI Build and Upload Process');
    print('=' * 50);

    final currentDir = Directory.current.path;
    final projectRoot = currentDir.endsWith('shell')
        ? Directory.current.parent.path
        : currentDir;

    final appDir = path.join(projectRoot, 'apps', 'lt_app');
    if (!await Directory(appDir).exists()) {
      throw Exception('App directory not found: $appDir');
    }

    print('📁 App directory: $appDir');
    print('');

    // Step 1: Clean and Setup
    await _setupEnvironment(appDir);

    // Step 2: Build IPA
    final ipaPath = await _buildIpa(appDir);

    // Step 3: Upload to TestFlight
    await _uploadToTestFlight(ipaPath, results);

    print('\n' + '=' * 50);
    print('✅ CI Process completed successfully!');
    print('=' * 50);
  } catch (e) {
    print('\n❌ Error: $e');
    print('\nUse --help to see usage information');
    exit(1);
  }
}

void _printHelp(ArgParser parser) {
  print('iOS CI Build and Upload Tool');
  print('');
  print('Usage: dart build_ios.dart [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  dart build_ios.dart -u your@email.com -p xxxx-xxxx-xxxx-xxxx');
  print('  dart build_ios.dart --api-key XXXXXXX --api-issuer XXXXXXX');
}

Future<void> _setupEnvironment(String appDir) async {
  print('📦 Step 1: Setting up environment...');

  stdout.write('    ⏳ Cleaning flutter project... ');
  final cleanResult = await Process.run('fvm', [
    'flutter',
    'clean',
  ], workingDirectory: appDir);
  if (cleanResult.exitCode == 0) {
    print('✓');
  } else {
    print('❌');
    throw Exception('Failed to run flutter clean:\n${cleanResult.stderr}');
  }

  stdout.write('    ⏳ Fetching dependencies... ');
  final pubGetResult = await Process.run('fvm', [
    'flutter',
    'pub',
    'get',
  ], workingDirectory: appDir);
  if (pubGetResult.exitCode == 0) {
    print('✓');
  } else {
    print('❌');
    throw Exception('Failed to run flutter pub get:\n${pubGetResult.stderr}');
  }
  print('');
}

Future<String> _buildIpa(String appDir) async {
  print('🔨 Step 2: Building IPA (Manual Signing)...');

  // Create ExportOptions.plist for manual signing
  final exportOptionsFile = File(path.join(appDir, 'ExportOptions.plist'));
  final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>com.little.things</key>
		<string>littile_things_distribute_profile</string>
	</dict>
	<key>signingStyle</key>
	<string>manual</string>
	<key>stripSwiftSymbols</key>
	<true/>
	<key>manageAppVersionAndBuildNumber</key>
	<true/>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>''';
  await exportOptionsFile.writeAsString(plistContent);

  // Stream the output because the build process takes a long time
  final process = await Process.start('fvm', [
    'flutter',
    'build',
    'ipa',
    '--export-options-plist=${exportOptionsFile.path}',
  ], workingDirectory: appDir);

  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);

  final exitCode = await process.exitCode;

  // Clean up
  if (await exportOptionsFile.exists()) {
    await exportOptionsFile.delete();
  }

  if (exitCode != 0) {
    throw Exception('Failed to build IPA');
  }

  // Find the generated IPA
  final ipaDir = Directory(path.join(appDir, 'build', 'ios', 'ipa'));
  if (!await ipaDir.exists()) {
    throw Exception('IPA output directory not found at ${ipaDir.path}');
  }

  final ipaFiles = await ipaDir
      .list()
      .where((e) => e.path.endsWith('.ipa'))
      .toList();
  if (ipaFiles.isEmpty) {
    throw Exception('No .ipa file found in ${ipaDir.path}');
  }

  final ipaPath = ipaFiles.first.path;
  print('\n✓ IPA built successfully at: $ipaPath\n');
  return ipaPath;
}

Future<void> _uploadToTestFlight(String ipaPath, ArgResults results) async {
  print('☁️ Step 3: Uploading to TestFlight...');

  final appleId = results['apple-id'] as String?;
  final password = results['password'] as String?;
  final apiKey = results['api-key'] as String?;
  final apiIssuer = results['api-issuer'] as String?;

  final List<String> xcrunArgs = [
    'altool',
    '--upload-app',
    '-f',
    ipaPath,
    '-t',
    'ios',
  ];

  if (apiKey != null && apiIssuer != null) {
    xcrunArgs.addAll(['--apiKey', apiKey, '--apiIssuer', apiIssuer]);
  } else if (appleId != null && password != null) {
    xcrunArgs.addAll(['-u', appleId, '-p', password]);
  } else {
    print(
      '⚠️  No App Store Connect credentials provided. Skipping upload step.',
    );
    print(
      '   Provide --apple-id and --password, OR --api-key and --api-issuer to upload.',
    );
    return;
  }

  print('    ⏳ Running xcrun altool...');
  final process = await Process.start('xcrun', xcrunArgs);

  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception(
      'Failed to upload IPA to TestFlight. Please check credentials and output above.',
    );
  }

  print('\n✓ Successfully uploaded to TestFlight!');
}
