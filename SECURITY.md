# Security Policy

## Supported versions

Only the latest minor version receives security fixes. Older versions are considered end-of-life once superseded.

| Version | Supported          |
| ------- | ------------------ |
| 0.3.x   | :white_check_mark: |
| < 0.3   | :x:                |

## Reporting a vulnerability

If you discover a security vulnerability in `solar_iconkit`, please **do not open a public issue**. Instead, report it privately so the maintainer can prepare a fix before the details become public.

### How to report

- **Preferred**: use GitHub's [private vulnerability reporting](https://github.com/sovankentech/solar_iconkit/security/advisories/new) — this creates a private advisory that only the maintainer can see.
- **Alternative**: email [sovanken.tech@gmail.com](mailto:sovanken.tech@gmail.com) with the subject line `[SECURITY] solar_iconkit — <short summary>`.

### What to include

Please provide:

1. A clear description of the vulnerability and its impact
2. Steps to reproduce, ideally with a minimal Dart / Flutter code sample
3. The version(s) of `solar_iconkit` affected
4. Any suggested mitigation or patch you've identified

### What to expect

- **Acknowledgement**: within 3 business days
- **Initial assessment**: within 7 business days
- **Fix + advisory**: within 30 days for confirmed vulnerabilities, or sooner for critical issues
- **Public disclosure**: coordinated after the fix ships on pub.dev

### Scope

`solar_iconkit` is a small package with a limited attack surface:

- Renders bundled SVG assets from `flutter_svg` at runtime
- No network requests, no file system writes, no dynamic code execution
- No user input parsing beyond an icon name string

Vulnerabilities in `flutter_svg` (our sole runtime dependency) should be reported to that project directly. This policy covers issues in code and assets shipped by `solar_iconkit`.

### Recognition

Reporters who follow this policy will be credited in the CHANGELOG and the corresponding GitHub advisory (unless anonymity is requested).

Thank you for helping keep the ecosystem safe.
