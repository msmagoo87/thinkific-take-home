# Service Level Objectives (SLO): DumbKV

This document defines the reliability targets for the **DumbKV** service.

## Service Level Indicators (SLIs)
We track two primary indicators to measure the health of the DumbKV service:

* **Availability SLI**: The proportion of valid requests that result in a successful application response.
    * **Calculation**: `http_requests_total{status=~"5.."}` / `http_requests_total`
    * **Note**:
      5xx responses are considered failures as they indicate server-side issues.
      4xx responses are treated as successful from a reliability perspective, as they represent client errors rather than system faults.
* **Latency SLI**: The time taken to serve a request, measured using Prometheus histogram metrics.
    * **Calculation**:
      90th percentile latency derived from `http_request_duration_seconds_bucket` using PromQL.

These SLIs are collected via Prometheus and visualized using Grafana dashboards for real-time monitoring and alerting.

## Service Level Objectives (SLOs)
Based on the proposed architecture, we define the following targets over a **30-day window**:

| Metric | Target | Description |
| :--- | :--- | :--- |
| **Availability** | **99.9%** | The service must be available for all but ~43 minutes per month, allowing flexibility for deployments and incident recovery. |
| **Read Latency** | **< 150ms** | 90% of `GET` requests must be completed within 150ms. |
| **Write Latency** | **< 300ms** | 90% of `PUT/DELETE` requests must be completed within 300ms. |

The selected targets are based on balancing user experience with system cost and complexity.

## The Error Budget
The **Error Budget** is the inverse of our SLO. For a 99.9% availability target, we have an error budget of **0.1%**, which can be used to balance reliability and feature velocity.

* **Budget Definition**: In a window of 1,000,000 requests, we are permitted 1,000 failures.
* **Budget Exhaustion Policy**: If the budget is exhausted, the following actions are triggered:
    1.  **Feature Freeze**: All non-emergency production deployments are halted to prevent further instability.
    2.  **Reliability Sprint**: The engineering team focus shifts exclusively to reliability improvements and infrastructure hardening.
    3.  **Post-Mortem**: A blameless root-cause analysis (RCA) is conducted to identify and remediate the systemic cause (or causes) of the on-going issues.
* **Alerting Strategy**: Burn rate alerts would be configured to detect rapid error budget consumption over short time windows, enabling faster incident response.