# token-vault — README

A simple STX vault contract (Clarity) that tracks per-user balances, supports deposit/withdraw, and includes owner-only admin controls (pause/unpause, emergency drain).

Quick facts
- Contract file: contracts/token-vault.clar
- Owner is the deployer: (define-constant contract-owner tx-sender)
- Balances: stored in a map `user-balances` keyed by principal
- Events: stored in data-vars (`deposit-event`, `withdraw-event`, `admin-drain-event`)
- Pause pattern: `vault-paused` data-var + `when-not-paused` private check
- Deposit API accepts explicit amount (see notes below)

Why deposit accepts an explicit amount
- Some Clarity environments do not expose stx-get-transfer-amount. To avoid unresolved-builtin compile errors, deposit takes an explicit (amount uint) parameter and records it in storage. Callers must attach the STX transfer in the same transaction or coordinate off-chain — the contract records the amount but does not independently verify the transfer when the builtin is unavailable.

Common commands
- Run tests (if package.json scripts present): npm test
- Clarinet checks / run tests: clarinet check  or  clarinet test
- Lint / format: use your standard Clarity tooling (not enforced in repo)

Important workflows & notes
- Before modifying storage schemas (maps / data-vars), bump tests that rely on initial states.
- Administrative functions require the deployer account (contract-owner); changing owner requires redeploy.
- Withdraw and admin-drain use stx-transfer? which fails if the contract lacks funds — ensure on-chain balance before calling these functions.
- Read-only getters:
  - get-balance (user principal)
  - get-vault-balance
  - is-paused

Examples
- Deposit (off-chain must include STX transfer in same tx): call deposit with desired amount uint
- Withdraw: call withdraw with amount; the contract updates the map then calls stx-transfer?

Files to inspect for patterns
- contracts/token-vault.clar — core contract and patterns (errors, pausable, owner-only)
- tests/ — unit/integration tests (examples of how functions are invoked in this repo)
- Clarinet.toml / package.json — test and environment configuration

If you want this README written into a file in the repo, tell me where (or confirm default: .github/README.md or README.md) and I will create it.
```# token-vault — README

A simple STX vault contract (Clarity) that tracks per-user balances, supports deposit/withdraw, and includes owner-only admin controls (pause/unpause, emergency drain).

Quick facts
- Contract file: contracts/token-vault.clar
- Owner is the deployer: (define-constant contract-owner tx-sender)
- Balances: stored in a map `user-balances` keyed by principal
- Events: stored in data-vars (`deposit-event`, `withdraw-event`, `admin-drain-event`)
- Pause pattern: `vault-paused` data-var + `when-not-paused` private check
- Deposit API accepts explicit amount (see notes below)

Why deposit accepts an explicit amount
- Some Clarity environments do not expose stx-get-transfer-amount. To avoid unresolved-builtin compile errors, deposit takes an explicit (amount uint) parameter and records it in storage. Callers must attach the STX transfer in the same transaction or coordinate off-chain — the contract records the amount but does not independently verify the transfer when the builtin is unavailable.

Common commands
- Run tests (if package.json scripts present): npm test
- Clarinet checks / run tests: clarinet check  or  clarinet test
- Lint / format: use your standard Clarity tooling (not enforced in repo)

Important workflows & notes
- Before modifying storage schemas (maps / data-vars), bump tests that rely on initial states.
- Administrative functions require the deployer account (contract-owner); changing owner requires redeploy.
- Withdraw and admin-drain use stx-transfer? which fails if the contract lacks funds — ensure on-chain balance before calling these functions.
- Read-only getters:
  - get-balance (user principal)
  - get-vault-balance
  - is-paused


- Clarinet.toml / package.json — test and environment configuration

If you want this README written into a file in the repo, tell me where (or confirm default: .github/README.md or README.md) and I will create it.
