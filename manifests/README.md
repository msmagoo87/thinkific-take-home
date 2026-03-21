# Kubernetes Manifests: DumbKV

This directory contains the production-hardened Kubernetes manifests for the `dumbkv` service. The configuration is designed for high security and persistence using the **EFS** storage class.

---

## Architecture Overview

* **Deployment**: A single-replica deployment using the `Recreate` strategy to ensure data integrity for SQLite.
* **Storage**: Persistent storage via an EFS-backed `PersistentVolumeClaim`.
* **Networking**: A `ClusterIP` service exposed via a TLS-enabled `Ingress`.
* **Security**: Hardened Pod Security Contexts (Non-root, Read-only FS).

---

## Deployment

### Prerequisites
1.  A Kubernetes cluster with an active **Ingress Controller** (e.g., NGINX).
2.  The **EFS CSI Driver** installed and a StorageClass named `efs` configured.
3.  **Cert-manager** (optional, for the Ingress TLS).

### Commands
```bash
# 1. Apply the configuration and storage
kubectl apply -f configmap.yaml
kubectl apply -f pvc.yaml

# 2. Deploy the application
kubectl apply -f deployment.yaml

# 3. Expose the service
kubectl apply -f service.yaml
kubectl apply -f ingress.yam
```

## Configuration

The application's storage behavior is managed via the `dumbkv-config` ConfigMap.

| Key | Default | Description |
| :--- | :--- | :--- |
| `DATABASE_TYPE` | `sqlite` | Switch to `postgres` for horizontal scaling. |
| `DATABASE_LOCATION` | `/dumbkvstore/dumbkv.db` | Path within the persistent volume. |

---

## Security Hardening

To satisfy production standards, the following security measures are implemented in `deployment.yaml`:

* **Read-Only Root Filesystem**: The container's root FS is immutable. Writable access is strictly limited to the `/dumbkvstore` (PVC) and `/tmp` (`emptyDir`) mounts.
* **Non-Root Execution**: The container runs as UID `10001`.
* **Resource Limits**: Strict CPU and Memory limits are enforced to prevent "noisy neighbor" effects and ensure cluster stability.
* **Privilege Escalation**: Explicitly disabled via `allowPrivilegeEscalation: false`.

---

## Storage & Scaling

### SQLite Constraints
Because SQLite does not support concurrent writes from multiple processes, this deployment is pinned to `replicas: 1`. 

### The `Recreate` Strategy
Standard `RollingUpdate` strategies attempt to start a new pod before killing the old one. This would cause a **Database Lock** error as both pods attempt to claim the volume. The `Recreate` strategy ensures the old pod is terminated (releasing the lock) before the new pod initializes.