# Security

- Supabase/Postgres with RLS-first design.
- Ownership checks are database-enforced where possible.
- No payment-provider secrets in frontend code.
- Payment, ledger and allocation writes are server-only.
- Rights-locked media requires authorization.
- Audit history is preserved.
