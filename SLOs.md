# Service Level Objectives (SLO): DumbKV

This document defines the reliability targets for the **DumbKV** service.

**NOTE**: Grafana can be used to visualize SLIs and build dashboards.

## Service Level Indicators (SLIs)
We track two primary indicators to measure the health of the DumbKV service:

* **Availability SLI**: The proportion of valid HTTP requests that return a successful (non-5xx) response code.
    * **Calculation**: (Total Successful Requests (2xx, 4xx) / Total Valid Requests) x 100
* **Latency SLI**: The time taken to serve a request, measured at the Application's `/metrics` endpoint.
    * **Calculation**: The 90th percentile of request duration for all `GET` and `POST` operations.

## Service Level Objectives (SLOs)
Based on the proposed architecture, we define the following targets over a **30-day window**:

| Metric | Target | Description |
| :--- | :--- | :--- |
| **Availability** | **99.9%** | The service must be available for all but ~43 minutes per month. |
| **Read Latency** | **< 150ms** | 90% of `GET` requests must be completed within 150ms. |
| **Write Latency** | **< 300ms** | 90% of `PUT/DELETE` requests must be completed within 300ms. |

## The Error Budget
The **Error Budget** is the inverse of our SLO. For a 99.9% availability target, we have an error budget of **0.1%**, which can be used to balance reliability and feature velocity.

* **Budget Definition**: In a window of 1,000,000 requests, we are permitted 1,000 failures.
* **Budget Exhaustion Policy**: If the budget is exhausted, the following actions are triggered:
    1.  **Feature Freeze**: All non-emergency production deployments are halted to prevent further instability.
    2.  **Reliability Sprint**: The engineering team focus shifts exclusively to reliability improvements and infrastructure hardening.
    3.  **Post-Mortem**: A blameless root-cause analysis (RCA) is conducted to identify and remediate the systemic cause (or causes) of the on-going issues.

### Single Points of Failure

* Prometheus is a single point of failure