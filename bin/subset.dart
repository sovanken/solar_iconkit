// Generates a trimmed Solar asset set for an app, so it ships only the icons
// and styles it actually uses.
//
// The full package bundles 7,614 SVGs (~5.8 MB) and Flutter's tree-shaker
// cannot drop any of them, because SolarIcon resolves asset paths at runtime.
// Until now the only remedy was to fork the package and delete folders by
// hand, which meant giving up versioned dependency management.
//
//   dart run solar_iconkit:subset --styles linear,bold
//
// It scans your Dart sources for icon usage, copies just those SVGs into
// your app, and prints the pubspec entry and the two lines of setup needed.
import 'dart:io';

const _styleFolders = <String, String>{
  'linear': 'linear',
  'outline': 'outline',
  'broken': 'broken',
  'bold': 'bold',
  'lineDuotone': 'line_duotone',
  'line-duotone': 'line_duotone',
  'boldDuotone': 'bold_duotone',
  'bold-duotone': 'bold_duotone',
};

void main(List<String> args) async {
  if (args.contains('-h') || args.contains('--help')) {
    _usage();
    return;
  }

  final styles =
      _option(args, '--styles')?.split(',') ?? _styleFolders.keys.toList();
  final scanDirs = (_option(args, '--scan') ?? 'lib').split(',');
  final outDir = _option(args, '--out') ?? 'assets/solar';
  final includeAll = args.contains('--all');

  final folders = <String>{};
  for (final s in styles) {
    final folder = _styleFolders[s.trim()];
    if (folder == null) {
      stderr.writeln(
          "Unknown style '$s'. Known: ${_styleFolders.keys.join(', ')}");
      exit(2);
    }
    folders.add(folder);
  }

  final packageRoot = await _locatePackage();
  if (packageRoot == null) {
    stderr.writeln('Could not locate solar_iconkit. Run this from an app that '
        'depends on it, after `flutter pub get`.');
    exit(2);
  }

  final catalog = _readCatalog(packageRoot);
  if (catalog.isEmpty) {
    stderr.writeln('Could not read the icon catalog from $packageRoot.');
    exit(2);
  }

  final Set<String> wanted;
  if (includeAll) {
    wanted = catalog.values.toSet();
    stdout.writeln('Including all ${wanted.length} icons (--all).');
  } else {
    final dynamicUse = _dynamicUsage(scanDirs);
    if (dynamicUse.isNotEmpty) {
      final listing = StringBuffer();
      for (final f in dynamicUse) {
        listing.writeln('  $f');
      }
      stderr.writeln(
        'Refusing to subset: these files build icon names at runtime, so '
        'scanning source cannot tell which icons the app needs.',
      );
      stderr.write(listing);
      stderr.writeln(
        'An app that renders SolarIcons.all or SolarIcons.categories needs '
        'the whole set. Re-run with --all to copy everything (still useful '
        'for dropping unused *styles*), or pass --scan pointing only at code '
        'with literal icon names.',
      );
      exit(1);
    }

    wanted = _scan(scanDirs, catalog);
    if (wanted.isEmpty) {
      stderr.writeln('No icon usage found in ${scanDirs.join(', ')}.\n'
          'Looked for SolarIcons.<name> and SolarIcon(\'<name>\').\n'
          'Use --scan to point at your sources, or --all to include everything.');
      exit(1);
    }
    stdout.writeln(
        'Found ${wanted.length} icons used in ${scanDirs.join(', ')}.');
  }

  var copied = 0;
  var missing = 0;
  for (final folder in folders) {
    // Rewrite the folder from scratch: leaving a previous run's icons behind
    // would quietly undo the size saving this tool exists to provide.
    final dest = Directory('$outDir/$folder');
    if (dest.existsSync()) dest.deleteSync(recursive: true);
    dest.createSync(recursive: true);
    for (final name in wanted) {
      final src = File('$packageRoot/assets/icons/$folder/$name.svg');
      if (!src.existsSync()) {
        missing++;
        continue;
      }
      src.copySync('${dest.path}/$name.svg');
      copied++;
    }
  }

  final bytes = Directory(outDir)
      .listSync(recursive: true)
      .whereType<File>()
      .fold<int>(0, (sum, f) => sum + f.lengthSync());

  stdout.writeln('Copied $copied SVGs into $outDir '
      '(${(bytes / 1024 / 1024).toStringAsFixed(2)} MB).');
  if (missing > 0) {
    stdout.writeln('$missing not found — likely renamed upstream; '
        'SolarIcon resolves those at runtime.');
  }
  stdout.writeln('''

Add to your pubspec.yaml:

flutter:
  assets:
${folders.map((f) => '    - $outDir/$f/').join('\n')}

And point SolarIcon at them once, before runApp:

  SolarIcon.assetBasePath = '$outDir';
  SolarIcon.assetPackage = null;

Re-run this after adding icons, or add --all to skip scanning.''');
}

/// Reads `SolarIcons.all` out of the installed package and rebuilds the
/// identifier -> name map with the generator's own rules, so
/// `SolarIcons.home2` in source can be matched back to `home-2`.
Map<String, String> _readCatalog(String packageRoot) {
  final file = File('$packageRoot/lib/src/solar_iconkit_data.g.dart');
  if (!file.existsSync()) return const {};
  final text = file.readAsStringSync();

  final out = <String, String>{};
  // Every declared constant, including the @Deprecated retired ones.
  // `dart format` wraps long declarations onto a second line, so the value
  // may not sit on the same line as the name.
  final decl = RegExp(r"static const String (\w+)\s*=\s*'([^']+)'");
  for (final m in decl.allMatches(text)) {
    out[m.group(1)!] = m.group(2)!;
  }
  return out;
}

/// Files that derive icon names at runtime. Scanning cannot see which icons
/// these need, and quietly shipping a subset would leave blank squares in a
/// released app — so the tool stops instead of guessing.
List<String> _dynamicUsage(List<String> dirs) {
  final dynamicApi = RegExp(r'SolarIcons\.(all|categories|legacyAliases)');
  final hits = <String>[];
  for (final dir in dirs) {
    final d = Directory(dir.trim());
    if (!d.existsSync()) continue;
    for (final file in d.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      if (dynamicApi.hasMatch(file.readAsStringSync())) hits.add(file.path);
    }
  }
  return hits;
}

/// Icon names referenced from the given directories.
Set<String> _scan(List<String> dirs, Map<String, String> catalog) {
  final byIdentifier = RegExp(r'SolarIcons\.(\w+)');
  final byLiteral = RegExp(r"""SolarIcon\(\s*['"]([a-z0-9-]+)['"]""");
  final names = catalog.values.toSet();
  final found = <String>{};

  for (final dir in dirs) {
    final d = Directory(dir.trim());
    if (!d.existsSync()) continue;
    for (final file in d.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final text = file.readAsStringSync();
      for (final m in byIdentifier.allMatches(text)) {
        final name = catalog[m.group(1)];
        if (name != null) found.add(name);
      }
      for (final m in byLiteral.allMatches(text)) {
        final name = m.group(1)!;
        if (names.contains(name)) found.add(name);
      }
    }
  }
  return found;
}

/// Finds the installed solar_iconkit via the package config Flutter writes.
Future<String?> _locatePackage() async {
  final config = File('.dart_tool/package_config.json');
  if (!config.existsSync()) return null;
  final text = config.readAsStringSync();
  final entry = RegExp(
    r'\{[^{}]*"name"\s*:\s*"solar_iconkit"[^{}]*\}',
  ).firstMatch(text);
  if (entry == null) return null;
  final root = RegExp(r'"rootUri"\s*:\s*"([^"]+)"').firstMatch(entry.group(0)!);
  if (root == null) return null;

  var uri = root.group(1)!;
  if (uri.startsWith('../')) {
    uri = Uri.file('${Directory.current.path}/.dart_tool/')
        .resolve(uri)
        .toFilePath();
  } else {
    uri = Uri.parse(uri).toFilePath();
  }
  return Directory(uri).existsSync() ? uri : null;
}

String? _option(List<String> args, String name) {
  final i = args.indexOf(name);
  if (i >= 0 && i + 1 < args.length) return args[i + 1];
  for (final a in args) {
    if (a.startsWith('$name=')) return a.substring(name.length + 1);
  }
  return null;
}

void _usage() {
  stdout.writeln('''
Generate a trimmed Solar icon set containing only what your app uses.

  dart run solar_iconkit:subset [options]

  --styles <list>  Styles to include, comma separated.
                   linear, outline, broken, bold, lineDuotone, boldDuotone.
                   Default: all six.
  --scan <dirs>    Directories to scan for usage. Default: lib
  --out <dir>      Where to write the subset. Default: assets/solar
  --all            Include every icon, skipping the usage scan.

Finds SolarIcons.<name> and SolarIcon('<name>') references.''');
}
