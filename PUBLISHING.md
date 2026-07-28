# Publishing solar_iconkit to pub.dev

Maintainer notes. End users do not need to read this.

## One-time setup

1. Register a Google account as a publisher at https://pub.dev.
2. Verify you can publish under your chosen publisher name (individual account or verified domain).
3. Replace the placeholder URLs in `pubspec.yaml`:
   - `homepage`
   - `repository`
   - `issue_tracker`
   - `documentation`
4. Update `LICENSE`'s package copyright line with the real authors/publisher name.
5. Push the repo to the URL declared in `repository:` — pub.dev links directly to it.

## Every release

1. **Regenerate icons if needed**
   ```bash
   python tools/fetch_icons.py
   ```
   Commit any resulting diff in `assets/` and `lib/src/solar_iconkit_data.g.dart`.

2. **Bump the version** in `pubspec.yaml` following [SemVer](https://semver.org):
   - Patch (`0.1.0 → 0.1.1`): bugfixes, asset refresh with no name changes.
   - Minor (`0.1.0 → 0.2.0`): new icons, new widget features, backward compatible.
   - Major (`0.1.0 → 1.0.0`): breaking API changes.

3. **Update `CHANGELOG.md`** with the new version and a summary of changes.

4. **Run pre-publish checks locally**:
   ```bash
   flutter analyze
   flutter test
   flutter pub publish --dry-run
   ```
   Fix any warnings before continuing. `dry-run` prints a summary of what
   would be uploaded and the pub.dev score-affecting issues.

5. **Tag the release**:
   ```bash
   git commit -am "Release 0.1.1"
   git tag v0.1.1
   git push && git push --tags
   ```

6. **Publish**:
   ```bash
   flutter pub publish
   ```
   The CLI opens a browser for authentication on the first run.

## After publishing

- Check the package on `https://pub.dev/packages/solar_iconkit`.
- The score is calculated within a few minutes. Aim for 130/140 or higher —
  the missing points are typically for platform tags or example tests.
- Announce the release wherever you announce releases (Slack, changelog blog,
  etc.).

## Pub.dev score checklist

The package aims for a 140/140 pub.dev score. The scoring rubric checks:

| Category | How this package satisfies it |
|---|---|
| Follows Dart file conventions | Public API in `lib/`, private code in `lib/src/`, snake_case filenames |
| Provides documentation | Comprehensive `README.md`, dartdoc on every public class/member |
| Provides an example | Full working `example/` directory with its own README |
| Platform support | Declared in `pubspec.yaml` under `platforms:` — Android, iOS, macOS, Windows, Linux, Web |
| Support for latest dependencies | `flutter_svg: ^2.0.10` (latest 2.x), Dart `^3.5.0` |
| Passes static analysis | `flutter analyze` clean under `flutter_lints` |
| Passes tests | `flutter test` passes |
| Meets metadata requirements | Description 60–180 chars, `homepage`, `repository`, `issue_tracker`, `topics`, `LICENSE` |

If pub.dev reports a lower score, the analysis page linked from your package's pub.dev URL explains exactly which check failed.

## Unpublishing

pub.dev does not allow deleting versions once published — you can only publish
a newer version that fixes the problem. Retract a version via:

```bash
dart pub token add https://pub.dev
dart pub retract 0.1.1  # marks 0.1.1 as retracted, but keeps it available
```

Retracted versions are hidden from search but still resolvable for existing
consumers.
