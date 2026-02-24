# Contributing to Kirby

Thanks for your interest in contributing!

## How to Contribute

1. Fork the repository
2. Create a feature branch: `git checkout -b my-feature`
3. Make your changes
4. Test with: `./kirby.sh --help` (syntax check) and a real run against a test project
5. Commit: `git commit -m "feat: description"`
6. Push and open a Pull Request

## What to Contribute

- Bug fixes in `kirby.sh`
- Improvements to `prompt.md` (better agent instructions)
- New skills in `skills/`
- Documentation improvements
- Support for additional AI tools

## Guidelines

- Keep `kirby.sh` POSIX-compatible where possible (bash 4+)
- Test changes with all three tools if possible (`--tool kiro`, `--tool amp`, `--tool claude`)
- Update CHANGELOG.md with your changes
- Update README.md if you change user-facing behavior

## Reporting Issues

Open an issue with:
- Which tool you're using (`kiro`, `amp`, `claude`)
- Your OS and shell version
- The error output
- Steps to reproduce
