To create a simple WebSocket server using **Axum** and **Tokio Tungstenite** that updates all connected clients when a task is created, we need to set up an Axum server, use the `tokio-tungstenite` crate to handle WebSocket connections, and use a shared state to broadcast updates to all connected devices.

Here’s how to do it:

1. **Add Dependencies**:
   In your `Cargo.toml`, add the required dependencies:

```toml
[dependencies]
tokio = { version = "1", features = ["full"] }
axum = "0.7"
tokio-tungstenite = "0.15"
tower = "0.4"
futures = "0.3"
serde = { version = "1", features = ["derive"] }
serde_json = "1.0"
```

2. **Create the Server**:
   Below is the code for a WebSocket server where each time a task is created, it is broadcast to all connected clients.

```rust
use axum::{routing::get, Router};
use futures::{SinkExt, StreamExt};
use std::sync::{Arc, Mutex};
use tokio::sync::broadcast;
use tokio_tungstenite::{tungstenite::protocol::Message, TokioAdapter};
use tower::ServiceBuilder;
use axum::extract::ws::{WebSocket, ws};
use std::collections::HashMap;

#[tokio::main]
async fn main() {
    // Set up the Axum app with WebSocket and broadcast
    let (tx, _) = broadcast::channel::<String>(100); // 100 is the capacity of the broadcast channel

    let app = Router::new()
        .route("/ws", get(ws_handler)) // WebSocket endpoint
        .layer(ServiceBuilder::new().service(axum::routing::get(ws_handler)))
        .with_state(Arc::new(Mutex::new(tx)));

    // Start the Axum server
    axum::Server::bind(&"0.0.0.0:8080".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}

// WebSocket handler, managing the connections and broadcasting the updates
async fn ws_handler(ws: WebSocket, tx: axum::extract::State<Arc<Mutex<broadcast::Sender<String>>>>) {
    // Join the broadcast channel
    let mut rx = tx.lock().unwrap().subscribe();

    // First send a message to all clients
    tokio::spawn(async move {
        // Forward messages from websocket to all
        while let Some(Ok(msg)) = ws.next().await {
            if let Message::Text(text) = msg {
                tx.lock().unwrap().send(text).unwrap();
            }
        }
    });

    // Broadcast all new messages to all connected devices
    tokio::spawn(async move {
        while let Ok(msg) = rx.recv().await {
            // send the broadcast message to all connected clients
            ws.send(Message::Text(msg)).await.unwrap();
        }
    });
}
```

### How It Works:

1. **WebSocket Endpoint (`/ws`)**:
   - When a WebSocket client connects, the server creates a WebSocket handler (`ws_handler`).
   - Each client is added to the broadcast channel (`tx`), allowing the server to send messages to all connected clients.

2. **Broadcasting a Task**:
   - In this example, when a message is received via WebSocket (sent by a client), it gets broadcasted to all the other connected clients using the `broadcast::Sender` that was shared between the connections.
   - Each connected client listens to the broadcast channel and receives new messages.
   
3. **Message Handling**:
   - Clients can send messages, and when the server receives a new message from one client, it broadcasts it to all connected clients. This simulates the "task creation" you mentioned.

4. **Concurrency**:
   - Since we're using `tokio::sync::broadcast`, all connected devices are kept in sync, meaning if a message is received by one device, it will automatically be broadcast to others.

### Test the Server:
To test this server:

1. Run the Rust code (`cargo run`).
2. Open multiple tabs in your browser (or use WebSocket clients).
3. Connect to `ws://localhost:8080/ws` from each client.
4. Any message sent from one client will be broadcast to all others.

This basic setup allows for communication between clients and broadcasting updates in real time with Tokio, Axum, and Tokio Tungstenite.
