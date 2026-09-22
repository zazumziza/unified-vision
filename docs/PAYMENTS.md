# Payments

Initial provider target: Pesapal.

Provider-specific integration must live behind a payment service boundary. Client success state is never authoritative. Verified provider callbacks/reconciliation should create canonical payment state and immutable ledger entries. Refund and chargeback state must remain represented explicitly.
