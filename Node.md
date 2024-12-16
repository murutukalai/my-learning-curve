Below is an example of a Rust program using the [kube-rs](https://github.com/kube-rs/kube-rs) library to dynamically scale the number of nodes in a Kubernetes cluster based on the number of active connections. This program assumes you have access to Kubernetes API and use a custom logic to determine when to create or delete nodes.

Keep in mind that Kubernetes doesn't allow directly adding or removing nodes using its API (nodes are typically managed by cloud providers or tools like Cluster Autoscaler). Instead, you might manage something like a deployment replica count or use a custom resource to coordinate node creation/deletion outside of Kubernetes (e.g., through cloud APIs).

Here's the Rust program:

```rust
use kube::{Client, Api, ResourceExt};
use kube::api::{PostParams, DeleteParams};
use k8s_openapi::api::core::v1::Pod;
use tokio::time::{self, Duration};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Kubernetes client
    let client = Client::try_default().await?;
    let pods: Api<Pod> = Api::namespaced(client.clone(), "default");

    // Simulated connection count (replace this with real metrics data)
    let connection_count = Arc::new(AtomicUsize::new(0));

    // Periodically check connection count and scale nodes
    let connection_count_clone = connection_count.clone();
    tokio::spawn(async move {
        let mut interval = time::interval(Duration::from_secs(10));
        loop {
            interval.tick().await;

            // Simulate connection count change
            let current_connections = connection_count_clone.fetch_add(10, Ordering::Relaxed);

            println!("Current connections: {}", current_connections);

            // Scale up or down based on the connection count
            if current_connections > 100 {
                // Scale up: Create a pod
                create_node(&pods).await.unwrap();
            } else if current_connections < 50 {
                // Scale down: Delete a pod
                delete_node(&pods).await.unwrap();
            }
        }
    });

    Ok(())
}

async fn create_node(pods: &Api<Pod>) -> Result<(), Box<dyn std::error::Error>> {
    let pod_name = format!("scaled-pod-{}", uuid::Uuid::new_v4());
    let pod = serde_json::json!({
        "apiVersion": "v1",
        "kind": "Pod",
        "metadata": { "name": pod_name },
        "spec": {
            "containers": [{
                "name": "nginx",
                "image": "nginx"
            }]
        }
    });

    println!("Creating pod: {}", pod_name);

    pods.create(&PostParams::default(), &pod).await?;
    Ok(())
}

async fn delete_node(pods: &Api<Pod>) -> Result<(), Box<dyn std::error::Error>> {
    let pod_list = pods.list(&Default::default()).await?;
    if let Some(pod) = pod_list.items.get(0) {
        let pod_name = pod.name_any();
        println!("Deleting pod: {}", pod_name);

        pods.delete(&pod_name, &DeleteParams::default()).await?;
    }
    Ok(())
}
```

### Explanation:
1. **Connection Simulation:** The `connection_count` variable is used to simulate a metric that drives scaling decisions. Replace this with a real metric source.
2. **Create a Pod:** The `create_node` function adds a new pod to the cluster. This could simulate scaling up capacity.
3. **Delete a Pod:** The `delete_node` function deletes one of the existing pods, simulating scaling down.
4. **Periodic Scaling:** The program checks the connection count every 10 seconds and adjusts the number of pods accordingly.

### Notes:
- This program works at the **pod level** instead of managing nodes directly.
- For actual node scaling, integrate with a cloud provider SDK or API to create/delete VM instances that register themselves as nodes in the Kubernetes cluster.
- Use proper logging, error handling, and configuration management for production-ready code.

Would you like an example for managing nodes directly with a cloud provider?
