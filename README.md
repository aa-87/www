# MUMPS.IO — public engineering workbench

An independent, account-free technical home for M practitioners. Modern editorial typography, classic terminal interfaces, responsive design, light/dark themes, self-hosted assets. Production application code is M; the browser uses small vanilla JavaScript for interactivity, with no build step.

## First release (review branch)

- SSR via MIOTPL, routes via MIOROUTE, responses via MIOHTTP, exact static asset allowlist via MIOSTATIC.
- Restricted console with real MIOSHA256, MIOSHA1, MIOUTIL, MIOFNC, MIOTPL calls and local sparse-array example. Optional MIOOS xterm frontend assets. **No direct-mode terminal, shell or arbitrary M evaluation exposed.**
- Searchable source index of 113 routines at the inspected upstream tree; links follow upstream main and may change. Includes internal and test routines, not a claim that every entry is a supported standalone API.
- MIOOS and TK-POP/AA-TABLES showcases, reference links, architecture illustration.

## Run locally

Use a dedicated YottaDB installation/database and service account; never point this site at the production MIO database. From this repository root, with the upstream mumps.io checkout available at a known absolute path:

```sh
# Source the YottaDB environment first; ensure ydb_gbldir is dedicated to this site.
export MIO_ROOT=/absolute/path/to/mumps.io
export ydb_routines="$PWD/routines $PWD/tests $MIO_ROOT/routines $ydb_routines"
export MWS_CONF="$PWD/config/mws.conf.json"
bash scripts/sync-assets.sh "$MIO_ROOT"
# For local development edit www.origin in config to http://127.0.0.1:9080.
yottadb -run ^MIOWWWT
yottadb -run START^MIOWWW 9080
```

Visit http://127.0.0.1:9080 locally. The custom START entry point intentionally does not invoke the upstream MIO start routine, register the desktop/registry/admin routes, or copy over MIO.m. Start from the repository root so relative template/static paths resolve. Stop the isolated instance using `yottadb -run STOP^MIOD` with the same database environment. MIO startup and network paths still need an end-to-end YottaDB test before deployment. Do not start the listener on an internet-reachable network without firewall restrictions.

For production see [security and deployment](docs/SECURITY.md). Example nginx config is not automatically installed. Set www.origin to the exact HTTPS origin, not a wildcard. Review upstream changes and pin a tested checkout. The optional xterm files are copied from MIOOS, not downloaded in the browser. Review upstream and TK-POP licensing before any redistribution; public source visibility alone is not a license grant.

## Verification

`yottadb -run ^MIOWWWT` tests known crypto/handshake vectors, local array and form output, and invalid commands. `node --check public/www/site.js` checks browser syntax (Node is optional development tooling). `bash -n scripts/sync-assets.sh` checks script syntax. The [security document](docs/SECURITY.md) defines launch gates; runtime and browser tests have not been executed by this implementation session.

## Roadmap

1. Validate this public SSR workbench, accessibility, crypto vectors, rate limits, error handling and proxy isolation.
2. Add individual routine documentation, safe typed demos, WebSocket lab and TK-POP interactive demonstration.
3. Add real anonymous YottaDB terminal by adapting MIOOS terminal transport to an independently isolated per-session worker; never enable its default host pipe on this application.
4. Add native M benchmark laboratory, advanced M idioms, portable runtime notes, documented package downloads and repeatable conformance tests.
