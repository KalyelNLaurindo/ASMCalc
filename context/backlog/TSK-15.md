# TSK-15: Structured Output Modality (JSON)

* **Owner / Assignee:** Kalyel N. Laurindo / Software Engineer  
* **Estimated Effort:** 8 Hours  
* **Story / Epic Reference:** RF02, RF09  
* **Development Methodology:** TDD / CLI Argument Parsing

## 📖 Description & Objectives

Enable the calculator to be used in non-interactive shell scripting and pipeline automation contexts:
1. **Command Line Flag**: Support a `--json` argument when launching `ASMCalc.exe`.
2. **Standardized JSON Schema**: Format outputs, errors, and intermediate calculation states into valid, minified or pretty JSON printed to `stdout`.
3. **Exit Codes**: Align execution exit codes (`0` for success, non-zero for calculations resulting in NaN/infinity or parsing errors) to simplify shell logic.

## ✅ Definition of Ready (DoR)
* [ ] JSON output schema defined (e.g. `{ "status": "success", "result": 12.5, "mode": "real" }`).
* [ ] Win32 command line argument parsing strategy established.

## 🏁 Definition of Done (DoD) & Acceptance Criteria
* [ ] **[Functional]:** Launching with `--json "<expression>"` evaluates, prints only JSON to stdout, and exits.
* [ ] **[Safety]:** Errors are correctly output as `{ "status": "error", "message": "<desc>" }`.
* [ ] **[Verification]:** Covered by integration tests invoking the CLI binary.

---
**Signature:** Kalyel N. Laurindo / Software Engineer
