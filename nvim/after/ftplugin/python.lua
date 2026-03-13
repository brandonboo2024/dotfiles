vim.opt_local.makeprg = "python3 %"


vim.opt_local.errorformat =
-- Ignore noise
    "%-GTraceback%.%#," ..
    "%-G(%*[0-9] of %*[0-9]):%.%#," ..

    -- === Traceback-style errors ===
    "%A%\\s%#File \"%f\"\\, line %l\\, in %.%#," ..
    "%+C%.%#," ..
    "%Z%[A-Za-z]%#Error: %m," ..

    -- === Single-block errors (IndentationError, SyntaxError sometimes) ===
    "%A%\\s%#File \"%f\"\\, line %l," ..
    "%Z%[A-Za-z]%#Error: %m"
