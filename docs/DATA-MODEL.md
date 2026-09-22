# Data Model

The initial migration favors explicit relational tables and uses JSONB only for genuinely extensible evidence/metadata fields.

Behavioral history is append-oriented. Financial and rights evidence is not destructively rewritten when derived algorithms change.

International-aware identifiers such as ISRC and ISWC are supported without making them mandatory at onboarding.
