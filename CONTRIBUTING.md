# Contributing to Kirby

Thanks for your interest in contributing!

## Development Setup

```bash
# Clone
git clone https://github.com/neosun100/kirby.git
cd kirby

# Verify script syntax
bash -n kirby.sh

# Run help
./kirby.sh --help
./kirby.sh --version
```

**Requirements:** Bash 4+, jq, and at least one of: kiro-cli, amp, claude.

## How to Contribute

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Make your changes
4. Test with: `bash -n kirby.sh` (syntax check) and a real run against a test project
5. Commit: `git commit -m "feat: description"`
6. Push and open a Pull Request

## What to Contribute

- Bug fixes in `kirby.sh`
- Improvements to `prompt.md` (better agent instructions)
- New skills in `skills/`
- Documentation improvements
- Support for additional AI tools

## Code Guidelines

- `kirby.sh` requires **Bash 4+** (uses `[[ ]]`, `${}`, arrays, `for (( ))`)
- Use `printf '%s\n'` instead of `echo` for variable content
- Quote all variable expansions: `"$VAR"` not `$VAR`
- Use heredoc with quoted delimiter (`<< 'EOF'`) to prevent shell injection
- Test changes with all three tools if possible (`--tool kiro`, `--tool amp`, `--tool claude`)

## Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `refactor:` Code restructuring
- `chore:` Maintenance tasks

## Checklist Before PR

- [ ] `bash -n kirby.sh` passes
- [ ] `./kirby.sh --help` works
- [ ] `./kirby.sh --version` works
- [ ] Updated CHANGELOG.md
- [ ] Updated README.md if you changed user-facing behavior

## Reporting Issues

Open an issue with:
- Which tool you're using (`kiro`, `amp`, `claude`)
- Your OS and shell version (`bash --version`)
- The error output
- Steps to reproduce
