# Recruitment Metrics Dashboard - PostgreSQL Schema

This file documents the schema objects created via CLI in one-statement-per-command fashion. Actual DDL was executed directly using the connection from `db_connection.txt`.

Connection (stored in db_connection.txt):
psql postgresql://appuser:dbuser123@localhost:5000/myapp

Extensions:
- uuid-ossp

Enums:
- candidate_status: applied, screening, interviewing, offered, hired, rejected, withdrawn
- interview_outcome: pending, passed, failed, no_show, rescheduled, offer_extended, offer_accepted, offer_declined

Tables:
- clients
  - id UUID PK (default uuid_generate_v4())
  - name TEXT NOT NULL
  - industry TEXT
  - contact_name TEXT, contact_email TEXT, contact_phone TEXT
  - status TEXT DEFAULT 'active'
  - created_at, updated_at TIMESTAMPTZ

- jobs
  - id UUID PK
  - client_id UUID FK -> clients(id) ON DELETE CASCADE
  - title TEXT NOT NULL
  - department, location, employment_type, seniority TEXT
  - openings INT DEFAULT 1
  - status TEXT DEFAULT 'open'
  - budget NUMERIC(12,2), currency TEXT DEFAULT 'USD'
  - posted_at, closed_at TIMESTAMPTZ
  - created_at, updated_at TIMESTAMPTZ

- candidates
  - id UUID PK
  - first_name, last_name TEXT NOT NULL
  - email, phone, linkedin_url TEXT
  - source, current_company, current_title TEXT
  - years_experience NUMERIC(4,1)
  - expected_salary NUMERIC(12,2), currency TEXT DEFAULT 'USD'
  - status candidate_status DEFAULT 'applied'
  - resume_url TEXT, notes TEXT
  - uploaded_at TIMESTAMPTZ
  - created_at, updated_at TIMESTAMPTZ

- applications
  - id UUID PK
  - candidate_id UUID FK -> candidates(id) ON DELETE CASCADE
  - job_id UUID FK -> jobs(id) ON DELETE CASCADE
  - applied_at TIMESTAMPTZ DEFAULT NOW()
  - stage TEXT DEFAULT 'applied'
  - status TEXT DEFAULT 'active'
  - rejected_reason TEXT
  - hired BOOLEAN DEFAULT FALSE
  - offer_amount NUMERIC(12,2)
  - offer_currency TEXT DEFAULT 'USD'
  - offer_extended_at, offer_accepted_at, hired_at TIMESTAMPTZ
  - UNIQUE(candidate_id, job_id)

- interviews
  - id UUID PK
  - application_id UUID FK -> applications(id) ON DELETE CASCADE
  - interview_type TEXT NOT NULL
  - scheduled_at TIMESTAMPTZ NOT NULL
  - duration_minutes INT
  - interviewer TEXT
  - outcome interview_outcome DEFAULT 'pending'
  - score NUMERIC(4,2)
  - feedback TEXT
  - rescheduled_from UUID FK -> interviews(id) ON DELETE SET NULL
  - created_at, updated_at TIMESTAMPTZ

- activities
  - id UUID PK
  - application_id, candidate_id, job_id, client_id UUID (nullable FKs, all ON DELETE CASCADE)
  - activity_type TEXT NOT NULL
  - activity_ts TIMESTAMPTZ DEFAULT NOW()
  - details JSONB DEFAULT '{}'::jsonb

- metrics_daily
  - id UUID PK
  - metric_date DATE NOT NULL
  - client_id UUID NULL FK -> clients(id) ON DELETE SET NULL
  - job_id UUID NULL FK -> jobs(id) ON DELETE SET NULL
  - total_candidates INT DEFAULT 0
  - new_candidates INT DEFAULT 0
  - total_applications INT DEFAULT 0
  - new_applications INT DEFAULT 0
  - interviews_scheduled INT DEFAULT 0
  - interviews_completed INT DEFAULT 0
  - offers_extended INT DEFAULT 0
  - offers_accepted INT DEFAULT 0
  - hires INT DEFAULT 0
  - rejections INT DEFAULT 0
  - time_to_hire_days NUMERIC(6,2)
  - created_at TIMESTAMPTZ DEFAULT NOW()

Indexes:
- candidates(status)
- candidates(uploaded_at)
- jobs(status)
- applications(candidate_id, job_id)
- interviews(application_id)
- interviews(scheduled_at)
- interviews(outcome)
- metrics_daily(metric_date)
- UNIQUE INDEX metrics_daily(metric_date, client_id, job_id)

Notes:
- All IDs are UUIDs with uuid_generate_v4().
- Timestamps default to NOW() where appropriate.
- The metrics_daily unique index ensures a single row per date/scope combination (NULLs are allowed and treated distinctly by Postgres).
- Activities table serves as an audit/timeline feed for dashboards.

How to re-run statements (example):
psql postgresql://appuser:dbuser123@localhost:5000/myapp -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"

