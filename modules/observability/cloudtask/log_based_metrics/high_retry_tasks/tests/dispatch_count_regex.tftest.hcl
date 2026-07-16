# Tests for the dispatch_count_regex local.
#
# All runs use command = plan so no GCP credentials are required.
# Assertions use can(regex(pattern, value)) — can() returns false when
# regex() finds no match instead of propagating the error.

variables {
  project_id = "fake-project"
  queue_id   = "fake-queue"
}

# ── threshold = 100 ──────────────────────────────────────────────────────────

run "threshold_100_boundary_below" {
  command = plan

  variables { dispatch_count_threshold = 100 }

  assert {
    condition     = !can(regex(output.dispatch_count_regex, "99"))
    error_message = "regex must not match 99 when threshold is 100"
  }
}

run "threshold_100_exact" {
  command = plan

  variables { dispatch_count_threshold = 100 }

  assert {
    condition     = can(regex(output.dispatch_count_regex, "100"))
    error_message = "regex must match exactly 100 when threshold is 100"
  }
}

run "threshold_100_above" {
  command = plan

  variables { dispatch_count_threshold = 100 }

  assert {
    condition = (
      can(regex(output.dispatch_count_regex, "101")) &&
      can(regex(output.dispatch_count_regex, "150")) &&
      can(regex(output.dispatch_count_regex, "999")) &&
      can(regex(output.dispatch_count_regex, "1000"))
    )
    error_message = "regex must match 101, 150, 999, 1000 when threshold is 100"
  }
}

# ── threshold = 150 (non-power-of-10) ────────────────────────────────────────

run "threshold_150_boundary_below" {
  command = plan

  variables { dispatch_count_threshold = 150 }

  assert {
    condition = (
      !can(regex(output.dispatch_count_regex, "100")) &&
      !can(regex(output.dispatch_count_regex, "149"))
    )
    error_message = "regex must not match 100 or 149 when threshold is 150"
  }
}

run "threshold_150_exact" {
  command = plan

  variables { dispatch_count_threshold = 150 }

  assert {
    condition     = can(regex(output.dispatch_count_regex, "150"))
    error_message = "regex must match exactly 150 when threshold is 150"
  }
}

run "threshold_150_above" {
  command = plan

  variables { dispatch_count_threshold = 150 }

  assert {
    condition = (
      can(regex(output.dispatch_count_regex, "151")) &&
      can(regex(output.dispatch_count_regex, "200")) &&
      can(regex(output.dispatch_count_regex, "1500"))
    )
    error_message = "regex must match 151, 200, 1500 when threshold is 150"
  }
}

# ── threshold = 999 (all 9s edge case) ───────────────────────────────────────

run "threshold_999_boundary_below" {
  command = plan

  variables { dispatch_count_threshold = 999 }

  assert {
    condition     = !can(regex(output.dispatch_count_regex, "998"))
    error_message = "regex must not match 998 when threshold is 999"
  }
}

run "threshold_999_exact_and_above" {
  command = plan

  variables { dispatch_count_threshold = 999 }

  assert {
    condition = (
      can(regex(output.dispatch_count_regex, "999")) &&
      can(regex(output.dispatch_count_regex, "1000"))
    )
    error_message = "regex must match 999 and 1000 when threshold is 999"
  }
}

# ── threshold = 1000 ─────────────────────────────────────────────────────────

run "threshold_1000_boundary_below" {
  command = plan

  variables { dispatch_count_threshold = 1000 }

  assert {
    condition     = !can(regex(output.dispatch_count_regex, "999"))
    error_message = "regex must not match 999 when threshold is 1000"
  }
}

run "threshold_1000_exact_and_above" {
  command = plan

  variables { dispatch_count_threshold = 1000 }

  assert {
    condition = (
      can(regex(output.dispatch_count_regex, "1000")) &&
      can(regex(output.dispatch_count_regex, "1001")) &&
      can(regex(output.dispatch_count_regex, "9999")) &&
      can(regex(output.dispatch_count_regex, "10000"))
    )
    error_message = "regex must match 1000, 1001, 9999, 10000 when threshold is 1000"
  }
}
