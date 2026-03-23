# Production Go-Live & Roll-out Plan

This document outlines the phased strategy for transitioning the Python KV service from local development to a production-grade environment on AWS EKS. The goal is to maximize reliability and minimize the blast radius of potential failures.

---

## Phase 1: Pre-Deployment Validation (The "Gatekeeper")
Before code is promoted to production, it must pass automated quality and security gates in the CI pipeline.

| Category | Tooling | Objective |
| :--- | :--- | :--- |
| **Security** | Trivy | Scan Docker images for High/Critical CVEs. |
| **Compliance** | Checkov / Kube-linter | Ensure manifests follow EKS best practices (non-root, resource limits). |
| **Performance** | k6 / Locust | Validate that the app handles 2x expected peak load in a staging environment. |
| **Integrity** | Pytest | 100% pass rate on unit and integration tests for KV logic. |

---

## Phase 2: Infrastructure & Data Readiness
We treat infrastructure as immutable, managed via Terraform/IaC.

1. **Secret Management**: Provision **AWS Secrets Manager** to store RDS credentials. Use the External Secrets Operator to sync these into Kubernetes as native Secrets.
2. **Database Provisioning**: 
   - Deploy Multi-AZ RDS Postgres for high availability.
   - Execute schema migrations first via an ArgoCD Sync Wave (or helm pre-hook, etc.)
   - **Critical Rule**: All migrations must be backward-compatible to allow the current "Live" version to function if a rollback occurs.

---

## Phase 3: Incremental Roll-out (Canary Strategy)
We will use a **Canary Deployment** to shift traffic gradually, monitored by the AWS Load Balancer Controller.

1. **Step 1 (5% Traffic)**: Spin up a single "Canary" pod. Direct 5% of production traffic to it.
2. **Step 2 (Observation)**: Monitor the **Golden Signals** for 15 minutes.
3. **Step 3 (25% -> 50%)**: If error rates are stable, increment traffic in 25% steps every 20 minutes.
4. **Step 4 (100% Traffic)**: Open the floodgates, as it were. 

---

## Phase 4: Success Criteria & SLOs
The roll-out is only considered "Complete" if the following Service Level Objectives (SLOs) remain healthy:

* **Availability SLI**: 
    $$Availability = \frac{\text{Total Requests} - \text{Failed Requests (5xx)}}{\text{Total Requests}} \ge 99.9\%$$
* **Latency SLI**: 
    $$P_{95} \text{ Latency} \le 200\text{ms}$$
* **Error Budget**: The deployment must not consume more than 5% of the monthly error budget.

---

### Phase 5: Failure Handling & Automated Decommissioning
Since this is an initial "Greenfield" deployment, there is no previous version to revert to. Our "Rollback" strategy focuses on **Automated Decommissioning** to ensure environment purity and cost control.

* **The Trigger**: If the application fails its `ReadinessProbes` or the ALB reports a >5% 5xx error rate during the linear traffic ramp-up.
* **The Action**: 
    1. **Traffic Termination**: Immediately set the ALB target group weight to 0.
    2. **Resource Cleanup**: Automated removal of application pods to free up EKS node resources.
    3. **Schema Assessment**: Flag the database for a manual "Sanity Check" before the next initialization attempt.
* **The Goal**: Ensure that a failed Day 0 deployment leaves the AWS environment in a "Clean Slate" state, preventing configuration drift or orphaned cloud resources.

---

## Phase 6: Post-Deployment & Handover
* **Cleanup**: Remove temporary migration logs and outdated EBS snapshots.
* **Dashboarding**: Verify the "Deployment Health" dashboard in Grafana is reflecting real-time production data.
* **Tagging**: Create a git tag (e.g., `prod-v1.2.3`) to mark