# Flowpulse

Flowpulse is a platform for creators, professionals, and people to build maps, journeys, services, and shared worlds.

## Vision

Flowpulse starts from a simple idea: life is a journey, and shared experience creates worlds.

The project explores how maps, journeys, services, and professional value can help people:

- build shared worlds
- structure personal and collective experience
- connect creators, professionals, and people through meaningful paths

## Current stack

- Ruby on Rails
- Hotwire
- Stimulus
- Importmap
- Tailwind CSS
- PostgreSQL

## Local setup

Install dependencies:

```bash
bundle install
```

Create and migrate the database:

```bash
bin/rails db:create
bin/rails db:migrate
```

Run the app in development:

```bash
bin/dev
```

## Current structure

The app currently includes:

- public home
- about page
- authentication and registration
- profile onboarding
- dashboard
- creator area
- professionals area
- superadmin creator requests

The `public/flowpulse_v_4/` folder still contains static HTML reference pages used as prototypes during the transition into Rails views.

## Documentation

Project notes and domain planning live in [`doc/`](doc/).

Key files:

- [`doc/visione_flowpulse.md`](doc/visione_flowpulse.md)
- [`doc/journey_ruoli.md`](doc/journey_ruoli.md)
- [`doc/valore_servizi_professionisti.md`](doc/valore_servizi_professionisti.md)
- [`doc/journey_service_offer_professional.md`](doc/journey_service_offer_professional.md)
- [`doc/professional_operativita.md`](doc/professional_operativita.md)
- [`doc/steps/README.md`](doc/steps/README.md)
- [`doc/steps/todo/planning_develop_step_0003.md`](doc/steps/todo/planning_develop_step_0003.md)
- [`doc/steps/done/planning_develop_step_0002.md`](doc/steps/done/planning_develop_step_0002.md)
- [`doc/steps/todonext/`](doc/steps/todonext/)

## Status

Flowpulse is still in active design and domain-definition phase.

The current priority is to stabilize:

- core language
- user roles
- journey structure
- branch and map architecture
- service and professional value model
