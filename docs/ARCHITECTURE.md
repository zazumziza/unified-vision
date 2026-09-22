# Architecture

BT follows the LDX loop:

REALITY → DOMAIN → MODEL → CANONICAL STATE → EVIDENCE → INTELLIGENCE → EXPERIENCE → ACTION → OBSERVATION → LEARNING

The frontend prototype is intentionally thin. Supabase/Postgres is the expected persistence boundary. Domain rules belong outside React components, with provider-specific services behind replaceable boundaries.
