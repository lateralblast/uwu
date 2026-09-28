# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.3] - 2026-09-29
### Fixed
- Broken array expansion (`$options['equal']` etc.) that made the default equal-check fallback never trigger.
- UPS status retry logic that slept but never re-queried `upsc`, so a failed read stayed empty.
- `getupsinfo`/`getinfo` requiring an unnecessary and non-interactive-unsafe `sudo` for `upsc`.
- `addups` action calling an undefined function; it now appends a `ups.conf` stanza from the configured UPS fields.
- Inverted "less than"/"greater than" labels in threshold check messages.
- Typo (`fale`) leaving comparison option state inconsistent after `--equal`/`--greater`.
- Leftover debug `echo` printed on every `--greater` invocation.
- Mismatched built-in help text for `alertstatus`/`checkstatus`/`postalertstatus` actions.
- Unquoted variable expansions flagged by shellcheck (word-splitting/globbing risk).
### Changed
- Standardized on `${command}` brace-expansion for consistency in `execute_command` call sites.

## [0.2.2] - 2026-04-06
### Added
- Missing UPS info function.

## [0.2.1] - 2026-04-06
### Added
- Retry logic if UPS status returns nothing.

## [0.2.0] - 2025-04-16
### Fixed
- Message.

## [0.1.9] - 2025-04-16
### Fixed
- Logic on value checks.

## [0.1.8] - 2025-04-15
### Fixed
- Bugs.

## [0.1.7] - 2025-04-15
### Fixed
- Print defaults.

## [0.1.6] - 2025-04-15
### Added
- Greater and less than functions.

## [0.1.5] - 2025-04-15
### Changed
- Updated slackalert message creation and documentation.

## [0.1.4] - 2025-04-14
### Added
- Name switch.
### Changed
- Updated documentation.

## [0.1.3] - 2025-04-14
### Changed
- Formatting improvements.

## [0.1.2] - 2025-04-14
### Added
- Initial working version.

## [0.1.1] - 2025-04-13
### Changed
- Formatting updates.

## [0.1.0] - 2025-04-13
### Changed
- Updates.

## [0.0.9] - 2024-12-23
### Fixed
- Bugfixes and improvements.

## [0.0.8] - 2024-12-22
### Changed
- Improved verbose message routine.

## [0.0.7] - 2024-12-22
### Changed
- Improved defaults and options handling.

## [0.0.6] - 2024-12-22
### Added
- Associative arrays.
### Fixed
- Bug fixes.

## [0.0.5] - 2024-12-20
### Fixed
- Force switch.

## [0.0.4] - 2024-12-13
### Changed
- Improved handling for switches that take values.

## [0.0.3] - 2024-09-05
### Added
- Force switch/option.
### Changed
- Updated documentation.

## [0.0.2] - 2024-09-05
### Added
- Modules support.

## [0.0.1] - 2024-09-05
### Added
- Initial version with some documentation.
