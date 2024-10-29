To set up `socketioxide` with Axum in Rust, let's go over an example of establishing a simple WebSocket connection, emitting events, and listening to them. I'll also include a basic test structure.

### 1. Add Dependencies
In your `Cargo.toml`, include the following dependencies:

```toml
[dependencies]
axum = "0.6"
socketioxide = "0.3"
tokio = { version = "1", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
```

### 2. Setting up a WebSocket Connection with `socketioxide`

Here’s a sample setup for a WebSocket server with `socketioxide` integrated into an Axum application.

```rust
use axum::{Router, routing::get, extract::Extension};
use socketioxide::prelude::*;
use std::sync::Arc;
use tokio::sync::Mutex;
use tower::ServiceBuilder;

#[tokio::main]
async fn main() {
    // Initialize the Socket.io server
    let io = SocketIo::new();
    
    // Create an instance of Axum router with an `Extension` for socket server
    let app = Router::new()
        .route("/ws", get(socket_handler))
        .layer(ServiceBuilder::new().layer(Extension(Arc::new(Mutex::new(io.clone())))));

    // Run the server
    axum::Server::bind(&"0.0.0.0:3000".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}

// WebSocket handler to handle client connections
async fn socket_handler(Extension(io): Extension<Arc<Mutex<SocketIo>>>) -> impl IntoResponse {
    let io = io.lock().await;
    io.on("message", |data: String, _| async move {
        println!("Received message: {}", data);
    });

    io.serve().await
}
```

### 3. Testing the Socket.io Server

Testing WebSocket-based code can be more complex due to the async nature of connections. You can use `tokio::test` for async tests and `socketioxide-client` to simulate a WebSocket client.

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use axum::Server;
    use tokio::spawn;
    use socketioxide_client::SocketIo;

    #[tokio::test]
    async fn test_socket_connection() {
        // Set up a background server
        spawn(async {
            main().await;
        });

        // Initialize client connection
        let client = SocketIo::connect("http://127.0.0.1:3000/ws").await.unwrap();

        // Test event emission
        client.emit("message", "Hello, server!").await.unwrap();

        // Verify server response (you may implement a response listener if needed)
        // For simplicity, we can assume no errors mean the connection is successful.
        client.disconnect().await.unwrap();
    }
}
```

This example sets up a WebSocket server with a `/ws` route in Axum. The server listens for a "message" event, and in the test, a client connects and emits a "message" event. The setup assumes the server runs successfully if no errors are thrown during the client's operations. 

Let me know if you need further customization or have specific events in mind!
