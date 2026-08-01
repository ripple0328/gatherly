# Gatherly — Operations and deployment

The current operations reference is the repository-root [OPS.md](../../OPS.md).
Shared implementation and provisioning documentation live in the sibling
`../mini-infra` repository.

Gatherly does not use the retired Platform checkout, a GitHub runner that resets
the Mini worktree, or repo-checkout releases. Its root `Justfile` delegates to
`../mini-infra/platform/Justfile`, which builds an immutable OTP release locally
with the mise-pinned toolchain and deploys it to launchd on the Mini.
