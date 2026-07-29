import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solar_iconkit/solar_iconkit.dart';

void main() => runApp(const SolarExampleApp());

class SolarExampleApp extends StatefulWidget {
  const SolarExampleApp({super.key});

  @override
  State<SolarExampleApp> createState() => _SolarExampleAppState();
}

class _SolarExampleAppState extends State<SolarExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = switch (_themeMode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solar Icon Kit',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _themeMode,
      home: HomePage(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
    );
  }
}

// ============================================================================
// HOME
// ============================================================================

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  SolarIconStyle _style = SolarIconStyle.linear;

  static const double _iconSize = 40;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    final all = List<String>.from(SolarIcons.all);
    if (_query.trim().isEmpty) return all;
    final q = _query.trim().toLowerCase();
    return <String>[
      for (final n in all)
        if (n.contains(q)) n,
    ];
  }

  IconData get _themeIcon => switch (widget.themeMode) {
        ThemeMode.light => Icons.light_mode_outlined,
        ThemeMode.dark => Icons.dark_mode_outlined,
        ThemeMode.system => Icons.brightness_auto_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final icons = _filtered;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                total: SolarIcons.all.length,
                filteredCount: icons.length,
                themeIcon: _themeIcon,
                onToggleTheme: widget.onToggleTheme,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyControls(
                background: scheme.surface,
                border: scheme.outlineVariant.withValues(alpha: 0.5),
                child: _ControlsPanel(
                  searchController: _searchController,
                  onSearchChanged: (v) => setState(() => _query = v),
                  style: _style,
                  onStyleChanged: (s) => setState(() => _style = s),
                ),
              ),
            ),
            if (icons.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 112,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.92,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final name = icons[i];
                      return _IconCard(
                        name: name,
                        style: _style,
                        size: _iconSize,
                        onTap: () => _showDetails(name),
                      );
                    },
                    childCount: icons.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDetails(String name) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => IconDetailSheet(name: name, initialStyle: _style),
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _Header extends StatelessWidget {
  const _Header({
    required this.total,
    required this.filteredCount,
    required this.themeIcon,
    required this.onToggleTheme,
  });

  final int total;
  final int filteredCount;
  final IconData themeIcon;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Solar Icon Kit',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  filteredCount == total
                      ? '${_formatNumber(total)} icons  ·  6 styles'
                      : '${_formatNumber(filteredCount)} of ${_formatNumber(total)} icons',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(themeIcon),
            tooltip: 'Toggle theme',
            style: IconButton.styleFrom(
              backgroundColor: scheme.surfaceContainerHighest,
              foregroundColor: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatNumber(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

// ============================================================================
// CONTROLS
// ============================================================================

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
    required this.searchController,
    required this.onSearchChanged,
    required this.style,
    required this.onStyleChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final SolarIconStyle style;
  final ValueChanged<SolarIconStyle> onStyleChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              filled: true,
              fillColor: scheme.surfaceContainerHighest,
              hintText: 'Search 1,231 icons...',
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: SolarIcon(SolarIcons.magnifer, size: 18),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 48, minHeight: 48),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const SolarIcon(SolarIcons.closeCircle, size: 18),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  );
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: scheme.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          _StyleSelector(
            value: style,
            onChanged: onStyleChanged,
          ),
        ],
      ),
    );
  }
}

class _StyleSelector extends StatelessWidget {
  const _StyleSelector({required this.value, required this.onChanged});

  final SolarIconStyle value;
  final ValueChanged<SolarIconStyle> onChanged;

  static const _labels = {
    SolarIconStyle.linear: 'Linear',
    SolarIconStyle.outline: 'Outline',
    SolarIconStyle.broken: 'Broken',
    SolarIconStyle.bold: 'Bold',
    SolarIconStyle.lineDuotone: 'Line Duo',
    SolarIconStyle.boldDuotone: 'Bold Duo',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        itemCount: SolarIconStyle.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 2),
        itemBuilder: (context, i) {
          final s = SolarIconStyle.values[i];
          final selected = s == value;
          return _SegmentChip(
            selected: selected,
            onTap: () => onChanged(s),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SolarIcon(SolarIcons.home2, style: s, size: 14),
                const SizedBox(width: 6),
                Text(_labels[s]!),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? scheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
              child: IconTheme(
                data: IconThemeData(
                  size: 14,
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// STICKY CONTROLS DELEGATE
// ============================================================================

class _StickyControls extends SliverPersistentHeaderDelegate {
  _StickyControls({
    required this.background,
    required this.border,
    required this.child,
  });

  final Color background;
  final Color border;
  final Widget child;

  @override
  double get minExtent => 128;

  @override
  double get maxExtent => 128;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: child),
          Divider(height: 1, color: border),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyControls old) =>
      old.background != background ||
      old.border != border ||
      old.child != child;
}

// ============================================================================
// ICON CARD
// ============================================================================

class _IconCard extends StatelessWidget {
  const _IconCard({
    required this.name,
    required this.style,
    required this.size,
    required this.onTap,
  });

  final String name;
  final SolarIconStyle style;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: scheme.primary.withValues(alpha: 0.08),
        highlightColor: scheme.primary.withValues(alpha: 0.04),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: SolarIcon(name, style: style, size: size),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: scheme.onSurfaceVariant,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SolarIcon(
            SolarIcons.magniferBug,
            style: SolarIconStyle.boldDuotone,
            size: 48,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No icons match your search',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DETAIL SHEET
// ============================================================================

class IconDetailSheet extends StatefulWidget {
  const IconDetailSheet({
    super.key,
    required this.name,
    required this.initialStyle,
  });

  final String name;
  final SolarIconStyle initialStyle;

  @override
  State<IconDetailSheet> createState() => _IconDetailSheetState();
}

class _IconDetailSheetState extends State<IconDetailSheet> {
  late SolarIconStyle _style = widget.initialStyle;

  static const _labels = {
    SolarIconStyle.linear: 'Linear',
    SolarIconStyle.outline: 'Outline',
    SolarIconStyle.broken: 'Broken',
    SolarIconStyle.bold: 'Bold',
    SolarIconStyle.lineDuotone: 'Line Duo',
    SolarIconStyle.boldDuotone: 'Bold Duo',
  };

  String get _dartIdentifier {
    final parts = widget.name.split(RegExp('[-_]+'));
    final head = parts.first.toLowerCase();
    final tail = parts.skip(1).map((p) {
      if (p.isEmpty) return '';
      return p[0].toUpperCase() + p.substring(1).toLowerCase();
    }).join();
    var ident = head + tail;
    if (ident.isNotEmpty && RegExp(r'^[0-9]').hasMatch(ident)) {
      ident = 'i$ident';
    }
    return ident;
  }

  String get _flutterCode =>
      'SolarIcon(SolarIcons.$_dartIdentifier, style: SolarIconStyle.${_style.name})';

  Future<void> _copy(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $label'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _labels[_style]!,
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              alignment: Alignment.center,
              child: SolarIcon(
                widget.name,
                style: _style,
                size: 96,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'All styles',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: SolarIconStyle.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final s = SolarIconStyle.values[i];
                  final selected = s == _style;
                  return Material(
                    color: selected
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => setState(() => _style = s),
                      child: Container(
                        width: 84,
                        padding: const EdgeInsets.all(12),
                        decoration: selected
                            ? null
                            : BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: scheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SolarIcon(
                              widget.name,
                              style: s,
                              size: 32,
                              color: selected
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurface,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _labels[s]!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? scheme.onPrimaryContainer
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Flutter usage',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: SelectableText(
                _flutterCode,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: scheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _copy(_flutterCode, 'Flutter code'),
                    icon: const SolarIcon(
                      SolarIcons.copy,
                      style: SolarIconStyle.linear,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text('Copy code'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copy(widget.name, 'icon name'),
                    icon: const SolarIcon(SolarIcons.tag, size: 18),
                    label: const Text('Copy name'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
