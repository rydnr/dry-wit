# Test Coverage Roadmap

This document outlines the steps required to reach **100% test coverage** for the `dry-wit` repository.

## Current Status

- Core modules under `modules/`: 30 files
- Existing core test files under `test/`: 23
- Extension modules under `modules/ext/`: 42 files
- Existing extension tests under `test/ext/`: 18
- Running `bash test/test-all.sh` currently shows several failing tests (e.g. `retrieveOwnIp` in `net-tests.sh`).

## Coverage Gaps

The most critical remaining gap is the lack of tests for the extension modules. All core modules now have at least basic test coverage thanks to newly added test suites for `locale`, `ssh`, `sudo` and `trap`.
## Plan to Reach 100%

1. **Establish Reliable Test Environment**
   - Ensure `dry-wit` binaries and modules are available under `~/.dry-wit/src`.
   - Use `PATH=$PWD/src:$PATH` when running tests to use local sources.
   - Provide a helper script (`scripts/setup-test-env.sh`) to populate the `~/.dry-wit` directory before executing tests.

2. **Add Missing Core Module Tests**
- Review existing core module tests and expand coverage with additional edge cases where needed.

3. **Expand Extension Module Coverage**
   - Introduce a new directory `test/ext/` for each extension module.
   - Start with frequently used modules such as `aws-cli`, `docker`, `curl`, `nix-flake`, etc.
   - Where external dependencies are required, use mocks or temporary local commands to avoid network access when possible.
  - Initial tests for the `curl` module now live under `test/ext/curl-tests.sh`.
  - Docker and nix-flake modules now have dedicated suites under `test/ext/`.
  - Additional coverage added for `gpg`, `helm`, and `rpm` modules.
  - New tests cover Nexus configuration helpers under `test/ext/nexus-tests.sh`.
  - `aws-cli` tests validate region and credential lookups under `test/ext/aws-cli-tests.sh`.
  - Additional suites now cover `p7zip`, `vault`, `ssl`, and `keytool` helper functions.
  - Further tests exercise `sed`, `filebeat`, `jetty`, `dyndns`, and `ubuntu` helpers.

4. **Track Coverage Metrics**
   - Integrate a coverage tool (e.g. `kcov` or `bashcov`) executed from `test/test-all.sh`.
   - Produce a coverage summary after running the entire suite and fail CI if coverage drops.

5. **Continuous Integration**
   - Add a simple GitHub Actions workflow to run `bash test/test-all.sh` on each pull request.
   - Include the coverage script to keep track of progress toward 100%.

6. **Documentation**
   - Update `README.md` with instructions on how to run the tests and interpret coverage output.
   - Document any required external tools or mocks used during testing.

Following this plan will gradually increase reliability and eventually provide full test coverage across all modules.
