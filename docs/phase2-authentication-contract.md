# Phase 2 — authentication contract

**Historical contract, September 22–23, 2026.** Reference client revision `d4ae7cf2dc058d82bc375faf44c6eecc3dd9fa84`; server revision `f42413eff8d59b04087b52d1b793a4c685de5a82`.

The client POSTs JSON containing `type=login`, email, password, version, and two-factor state. The local server accepts the initial non-enrolled TOTP path with `twoFactorAction=skip`; an already-protected account returns `errorCode=6`, while an enrollment offer returns `errorCode=7` and `twoFactorSetup`. Both are unsupported challenges for this increment and must never produce a session or bypass account protection.

Success requires `session` and `playdata`, an active `sessionkey`, at least one valid world, and a character linked by `worldid`. World endpoints prefer confirmed unprotected external fields for the lab, with documented protected/generic variants as fallback. Remote error messages are classified, not passed directly into rich text or logs. Passwords, session keys, tokens, and full bodies are never logged.

The coordinator permits one active attempt with monotonically increasing IDs. Cancellation ends the current attempt before aborting HTTP, so callbacks from canceled or older attempts cannot replace the terminal state. New attempts clear old session/failure data. Success, rejected credentials, unsupported challenge, incompatible response, timeout, and transport failure remain distinct. The core does not retain credentials or depend on Qt, sockets, or logging.

Character selection accepts exactly one uniquely named character in the active session and exactly one world by `worldId`. Missing/duplicate worlds, empty hosts, or absent ports fail. Changing/clearing the session invalidates prior selection. The result carries character, world, endpoint, and current session key to the TCP handshake.

Historical owner reports recorded 51/51 tests for codec cases, 60/60 after coordinator tests, 67/67 after synthetic loopback application tests, and 76/76 after selector tests. Each was a revision-specific external result, not a current run or real credential authentication by the agent.
