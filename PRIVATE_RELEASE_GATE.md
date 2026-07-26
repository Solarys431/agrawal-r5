# Private release gate

Status: **HOLD — private repository, no public announcement authorized.**

The project is being prepared so that publication, when authorized, is a
single controlled transition rather than a scramble.

## Gate A — mathematical integrity

- [x] Flagship factorization checked by Lean.
- [x] Quintic-index consequence checked for every character and for the
      explicit prime-field index.
- [x] Lenstra–Pomerance attribution corrected to the primary source.
- [x] Every open statement labelled as conjecture.
- [ ] Golden-moment priority checked by a human specialist in cyclotomy.
- [ ] Paper read end-to-end by a human mathematician independent of the
      model pipeline.

## Gate B — mechanical reproducibility

- [x] Pinned Lean toolchain and Mathlib revision.
- [x] `lake build --wfail`.
- [x] No `sorry`, `admit`, or project axioms.
- [x] Default certificate replay.
- [x] Full census replay available.
- [x] Private CI workflow builds with warnings as errors and replays
      certificates.
- [x] Clean-clone CI run observed on the private remote: commit `e51cd16`,
      workflow run `30201970510`, green on 2026-07-26.

## Gate C — scientific presentation

- [x] The paper leads with the new bridge, not with classical prior art.
- [x] Novelty and prior art separated result by result.
- [x] Human direction and LLM assistance disclosed.
- [x] Exact Lean declaration names included.
- [ ] Final human authorship decision.
- [ ] Stable public repository URL and archival identifier.

## Gate D — Lean community contact

A future Zulip message must be written by the human author in their own
words. It should ask one specific formalization question, state that the
project is LLM-assisted, and link to:

1. the exact theorem declaration;
2. a short paper section containing the mathematics;
3. a green reproducible build.

It should not ask the community to “look at the whole project”, and it should
not claim that kernel checking establishes mathematical novelty. These
constraints follow the Lean community’s published AI and contribution
guidelines.

## Release-killing conditions

Publication remains blocked if any of these occurs:

- a specialist finds the golden-moment bridge in prior art;
- a theorem statement in the paper is stronger than its Lean declaration;
- a certificate cannot replay from a clean clone;
- an “external review” claim cannot be tied to an actual human reviewer;
- the author line and AI disclosure are unresolved.
