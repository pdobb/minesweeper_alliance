# Minesweeper Alliance

[![CI](https://github.com/pdobb/minesweeper_alliance/actions/workflows/ci.yml/badge.svg)](https://github.com/pdobb/minesweeper_alliance/actions/workflows/ci.yml)

[Source Code](https://github.com/pdobb/minesweeper_alliance)

Welcome to Minesweeper Alliance, an open-multiplayer riff on the classic Minesweeper game. Join forces with your fellow allies to sweep mines in real-time!

## Development

Ruby version: 3.3.4+

To get started:

```bash
bin/setup
```

### Server

To easily allow for breakpoints, run the Rails server in its own process:

```bash
bin/rails server --port=3000
```

Then, run the tailwindcss server in a separate tab/process:

```bash
bin/dev web=0,all=1
```

### Services

- PostgreSQL
  - Services ActionCable as well as the usual data store.

### Test Suite

```bash
# Unit tests
bin/rake test

# System tests
bin/rake test:system
```

Or, run test, rubocop, reek, and test:system all at once:

```bash
bin/rake
```

## Deploys

First, push changes to GitHub:

```bash
git push origin main
```

Next, ... (TODO: No production server yet.)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pdobb/minesweeper_alliance. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/pdobb/minesweeper_alliance/blob/master/CODE_OF_CONDUCT.md).

## License

The app is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gemwork project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pdobb/minesweeper_alliance/blob/master/CODE_OF_CONDUCT.md).
