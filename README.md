## Trunk-Based Development CI/CD Demo

This repo demonstrates a trunk-based workflow with feature flags, automated testing, and progressive rollout onto an EC2 instance. It contains:
- FastAPI demo service in `app/`
- EC2 bootstrap script in `infra/scripts/`
- GitHub Actions pipeline in `.github/workflows/`

### Architecture
1. **Main branch** is always deployable. Short-lived feature branches merge quickly.
2. **Feature flags** managed via LaunchDarkly or Unleash toggle runtime behavior instead of long-lived branches.
3. **Automated testing** (unit + lint) runs on each PR and push to main via GitHub Actions.
4. **Progressive rollout** handled manually on EC2 by toggling flags and gradually exposing traffic.

### Local Development
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Deploy on EC2
```bash
scp -r . ubuntu@<ec2-ip>:/opt/trunk-demo
ssh ubuntu@<ec2-ip>
cd /opt/trunk-demo
chmod +x infra/scripts/setup_ec2.sh
./infra/scripts/setup_ec2.sh ubuntu /opt/trunk-demo
```

The script installs Python, configures a virtualenv, installs requirements, and creates a `systemd` service `trunk-demo.service`.

### GitHub Actions Pipeline
- Runs on every push and PR.
- Installs dependencies, runs linting via `ruff` (fast) and tests via `pytest`.
- Builds and stores an artifact with the FastAPI app.
- Deployment step is manual to EC2; use `scp` + `setup_ec2.sh`.

### Feature Flag Flow
1. Ship code guarded behind LaunchDarkly/Unleash flags.
2. Merge to `main`; toggles start disabled.
3. Use CI to ensure regressions are caught.
4. Enable flags gradually per environment.

### Progressive Rollout Checklist
1. Deploy latest `main` to staging EC2.
2. Toggle feature flag to limited internal audience.
3. Observe metrics/logs.
4. Increase rollout stage via `/rollout?stage=<n>` route and LaunchDarkly targeting.
5. When stable, enable for 100% of users.

