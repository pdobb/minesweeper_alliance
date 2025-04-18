# Minesweeper Alliance

[![CI](https://github.com/pdobb/minesweeper_alliance/actions/workflows/ci.yml/badge.svg)](https://github.com/pdobb/minesweeper_alliance/actions/workflows/ci.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)

Welcome to [Minesweeper Alliance](https://minesweeperalliance.net), an open-multiplayer riff on the classic Minesweeper game. Join forces with your fellow allies to sweep mines in real time!

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/pdobb/minesweeper_alliance/blob/main/public/screenshots/expert-dark.webp?raw=true">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/pdobb/minesweeper_alliance/blob/main/public/screenshots/expert-light.webp?raw=true">
  <img alt="Game Board" src="https://github.com/pdobb/minesweeper_alliance/blob/main/public/screenshots/expert-dark.webp?raw=true">
</picture>

## Development

Ruby version: 3.4+ (see: [`.ruby-version`](./.ruby-version))

To get started:

```bash
bin/setup
```

### Server

#### With Foreman

```bash
bin/dev
```

#### Without Foreman

If more control over the server processes is needed, they can be run without foreman.

e.g. To simplify breakpoints/debugging, run the Rails server in its own process:

```bash
bin/rails server --port=3000

# Or, to allow for testing via other browsers on local network:
bin/rails server --binding 0.0.0.0 --port=3000
```

... then run the tailwindcss server in a separate tab/process:

```bash
bin/rails tailwindcss:watch
```

#### Debug Mode

Use debug mode to show mines placement on the Game board, and to enable additional logging, etc. Search on `App.debug?`.

```bash
DEBUG=1 bin/rails server [...]
```

### Services

- PostgreSQL

### Test Suite

```bash
# Unit tests
bin/rails test

# Or
rake test
```

Or, run all checks at once. Currently: `test`, `rubocop`, `erb_lint`, `reek`, `eslint`, `prettier`, `brakeman`, and `validate`.

```bash
rake
```

If a failure occurs during one of the checks, the rest will be halted.

## Web App

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/pdobb/minesweeper_alliance/blob/main/public/screenshots/erd-dark.webp?raw=true">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/pdobb/minesweeper_alliance/blob/main/public/screenshots/erd-light.webp?raw=true">
  <img alt="Game Board" src="https://github.com/pdobb/minesweeper_alliance/blob/main/public/screenshots/erd-dark.webp?raw=true">
</picture>

Note: Much of the complexity in this app lies in the Home page (a.k.a. the War Room), which dynamically adjusts its content based on the Current Game state by:

1. Showing the "New Game" content when no Current Game exists, or
1. Showing the "Current Game" content when a Current Game does exist.

Plus, there are various ways of displaying past Games:

1. Just-Ended Games,
1. By Sweep Ops Archive context,
1. Via a "display case" under Metrics, or
1. By User context.

The overall structure of the view templates and [View Models](#view-models) to support this looks like:

```
Current Game:
- Status ("Standing By" vs "Sweep in Progress")
- Board -> Header + Content + Footer
- Rules of Engagement

Just Ended Game:
- Title
- Status ("Mines Win" vs "Alliance Wins")
- Board -> Header + Content + Footer
- Active Participants:
  - Signature
  - Results:
    - Metrics
    - Active Participants -> Duty Roster + Observers
- Observers (Passive Participants):
  - Results:
    - Metrics
    - Active Participants -> Duty Roster + Observers

Past Game (Sweep Ops Archive):
- Title
- Status ("Mines Win" vs "Alliance Wins")
- Board -> Header + Content + Footer
- Results -> Metrics + (Duty Roster + Observers)

Metrics -> Past Game:
- Title
- Board -> Header + Content + Footer
- Results -> Metrics + (Duty Roster + Observers)

User -> Past Game:
- Title
- Board -> Header + Content + Footer
- Results -> Metrics + (Duty Roster + Observers)

# Plus:
New Game:
- Standard: Beginner, Intermediate, or Expert
- Random (one of the Standard Games, plus a small chance for a random Pattern Game)
- Custom Game
```

### View Models

View Models are Plain Old Ruby Objects (POROs) that:

- Insulate view templates from ActiveRecord Models,
- Handle view-specific logic ("display" of Model attributes, conditionals, etc.),
- Live alongside the view templates/partials they support, and
- Are easily unit testable (where view template are not).

View Models are can be thought of as somewhat similar to, yet much simpler than, GitHub's ViewComponent pattern/gem. Notably different: they make no attempt to intervene in the rendering stack or to provide a custom DSL.

Again, View Models are just POROs, so the only thing to learn about them is when/where/how to apply them. Generally speaking, a View Model should be used any time a view template would otherwise need to interact with your ActiveRecord models or implement any kind of ERB logic/conditionals.

Notes:

- View Models exist because view templates should not have direct access to your ActiveRecord models. This is a slippery slope towards view templates shaping the design of or even inserting logic into your ActiveRecord models.
- View models should not be used for generating HTML. View templates should still render all of their own HTML while appealing to View Models for any non-static rendering logic.
- Using view models generally means there is no need for Rails' Helper modules outside of a few Application-level helpers.

### Users

Upon first visiting the site, users are represented by the Guest (non-participant) model. Users (participants) are automatically created upon first active participation with a Game.

New User creation generates a User record in the database, for which the primary key is a UUID. This UUID is then stored in an HTTP cookie for re-identification of the Current User in the future.

It is easily possible to create multiple User records per actual user (e.g. by visiting on different browsers or computers), but this is an acceptable price to pay for such a simple app... versus the pain of having to explicitly register as a User and then maintain credentials like every other site out there. The model here is that of arcade games: just enter your username after finishing a game and that's authentication enough.

That said, access to one's account may be shared or preserved by copying or bookmarking the "Authentication Link" on the Account page (accessed by clicking on one's username in the top-right corner). Re-visiting the linked URL later on will re-authenticate the User account by resetting the "Current User" cookie token.

#### Usernames / Signatures

At the end of any game, an option is presented for signing one's username (for all active participants). This may not only capture a point of pride, but will also unlock additional functionality on the site. For example:

- The ability to permanently hide the welcome banner at the top of the War Room page,
- A "New Custom Game" button/option for defining custom Game board settings,
- Direct access to User-specific "Best" Games and stats,
- And more...

#### Time Zone

The default Time Zone for this app is `Central Time (US & Canada)`. However, JavaScript is used to detect the Current User's local time zone. This is then used to set the current Time Zone for the duration of each request.

## UI Portal

Visit `/ui` while in the development environment to access the UI Portal. This portal acts as a playground / test bed when developing new UI/UX features.

## Dev Portal

Visit `/dev` while in the development environment to access the Dev Portal. This portal acts like an Admin Portal, except that is only available within the development environment.

### Patterns

Within the Dev Portal is the Patterns tool--used for creating pre-determined mine patterns on custom-sized Game boards. These patterns / Game Boards are selected by random luck when staring a new "Random" game.

Patterns may be imported/exported as CSV.

The mere presence of a Pattern in the database makes it eligible for being randomly selected for game play.

## Deploys

First, push changes to GitHub:

```bash
git push origin main
```

Next, deploy using Kamal: `kamal deploy`.

Note: Deploys require that the 1Password and Docker Desktop apps at least be running in the background. Deploy credentials are pulled from specifically-named 1Password entries and Docker Desktop manages building and uploading of containers.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pdobb/minesweeper_alliance. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/pdobb/minesweeper_alliance/blob/master/CODE_OF_CONDUCT.md).

## License

The app is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gemwork project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pdobb/minesweeper_alliance/blob/master/CODE_OF_CONDUCT.md).
