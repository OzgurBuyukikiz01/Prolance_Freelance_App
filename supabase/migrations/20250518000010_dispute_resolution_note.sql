-- Dispute resolution metadata
ALTER TABLE escrow_transactions
  ADD COLUMN IF NOT EXISTS resolution_note    TEXT,
  ADD COLUMN IF NOT EXISTS resolved_by        UUID REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS resolved_at        TIMESTAMPTZ;

-- Admin decision visible to both contract parties
ALTER TABLE proposals
  ADD COLUMN IF NOT EXISTS admin_resolution_note TEXT;
