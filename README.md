# BenchKit

A toolkit for creating ground truth datasets and benchmarking generative AI systems in enterprise contexts. Read the [paper](paper/paper.pdf) for the full methodology.

## Paper

BenchKit implements the benchmarking workflow described in _Benchmarking Workflow for Generative AI Systems_ — an end-to-end pipeline covering ground truth generation, performance benchmarking with statistical validation, and continuous monitoring. See [`paper/paper.pdf`](paper/paper.pdf) for details.

## Features

- **Manage** — CRUD for users, projects, and test cases with multi-file upload (PDF, image, JSON, text)
- **Review** — Validation UI with keyboard navigation, progress tracking, and annotation notes
- **Analyse** — Benchmark comparison with field-level diff via jsondiffpatch

## Quick Start

Prerequisites: Node 18+, pnpm, MongoDB

```bash
pnpm install
cp .env.example .env
pnpm dev
```

This starts MongoDB on port 27017 and Nuxt on `http://localhost:3000`.

If MongoDB is running elsewhere, update `MONGODB_URI` in `.env` and run:

```bash
pnpm dev:standalone
```

## Tech Stack

Nuxt 4, Vue 3, TypeScript, MongoDB / Mongoose, Nuxt UI, Tailwind CSS

## License

[MIT](LICENSE)
