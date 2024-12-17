To create a new service in **Jaeger** (self-hosted) using the **Rust Axum server** and integrate it with **OpenTelemetry**, follow these steps. Jaeger will be used to trace the distributed service calls.

Here’s a structured approach:

---

## **1. Prerequisites**

- Install **Rust** and **Cargo**.
- Ensure you have **Jaeger** set up and running locally or remotely.
- Add required dependencies to your `Cargo.toml`.

---

## **2. Dependencies**

Add the following dependencies to your `Cargo.toml`:

```toml
[dependencies]
axum = "0.6"                            # Axum web framework
tokio = { version = "1", features = ["full"] }   # Async runtime
opentelemetry = { version = "0.21", features = ["rt-tokio"] } 
opentelemetry-jaeger = "0.18"           # Jaeger exporter for OpenTelemetry
opentelemetry-http = "0.9"              # Integrates OpenTelemetry with HTTP
tracing = "0.1"                         # Tracing library
tracing-opentelemetry = "0.21"          # Connects tracing with OpenTelemetry
tracing-subscriber = { version = "0.3", features = ["env-filter", "fmt"] }
```

---

## **3. Initialize OpenTelemetry and Jaeger Exporter**

Create a function to initialize the OpenTelemetry tracing pipeline.

### **tracing_setup.rs**

```rust
use opentelemetry::sdk::{
    trace::{self, Tracer},
    Resource,
};
use opentelemetry::KeyValue;
use opentelemetry_jaeger::PipelineBuilder;
use tracing_opentelemetry::OpenTelemetryLayer;
use tracing_subscriber::prelude::*;
use tracing_subscriber::{fmt, layer::SubscriberExt};

pub fn init_tracing() -> Tracer {
    // Create the Jaeger pipeline
    let tracer = opentelemetry_jaeger::new_pipeline()
        .with_service_name("rust-axum-service")
        .install_batch(opentelemetry::runtime::Tokio)
        .expect("Error initializing Jaeger exporter");

    // Set up the tracing subscriber
    let telemetry = OpenTelemetryLayer::new(tracer.clone());
    let fmt_layer = fmt::layer();

    tracing_subscriber::registry()
        .with(telemetry)
        .with(fmt_layer)
        .try_init()
        .expect("Error initializing tracing");

    tracer
}
```

---

## **4. Create the Axum Server**

Here’s an example Axum server with tracing integrated.

### **main.rs**

```rust
use axum::{
    routing::get,
    http::StatusCode,
    Router,
};
use opentelemetry::global;
use std::net::SocketAddr;
use tracing::{info, instrument};
use tracing_opentelemetry::OpenTelemetrySpanExt;

mod tracing_setup;

#[tokio::main]
async fn main() {
    // Initialize tracing
    let _tracer = tracing_setup::init_tracing();

    // Create a simple route
    let app = Router::new()
        .route("/", get(root_handler))
        .route("/hello", get(hello_handler));

    // Run the Axum server
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    info!("Starting server on {}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();

    // Shutdown OpenTelemetry
    global::shutdown_tracer_provider();
}

#[instrument] // Adds tracing for the route
async fn root_handler() -> &'static str {
    "Welcome to Rust Axum with OpenTelemetry and Jaeger!"
}

#[instrument] // Traces this function
async fn hello_handler() -> (StatusCode, &'static str) {
    tracing::Span::current().set_attribute("custom-attr".into(), "hello-world".into());
    (StatusCode::OK, "Hello from Axum!")
}
```

---

## **5. Run Jaeger Locally**

Run Jaeger locally using Docker:

```bash
docker run -d --name jaeger \
  -p 6831:6831/udp \
  -p 16686:16686 \
  jaegertracing/all-in-one:1.48
```

- **Port 16686** is the UI for viewing traces.
- **Port 6831/UDP** is for accepting OpenTelemetry data.

---

## **6. Run Your Rust Service**

Start your Rust Axum service:

```bash
cargo run
```

Visit `http://127.0.0.1:3000/` or `http://127.0.0.1:3000/hello` to trigger the routes.

---

## **7. View Traces in Jaeger**

1. Open **Jaeger UI** at `http://localhost:16686`.
2. Search for traces under the `rust-axum-service` name.
3. Observe the traces and spans for the routes you called.

---

## **Summary of Components**

- **Axum**: HTTP server handling the API routes.
- **OpenTelemetry**: Instrumentation and trace collection.
- **Jaeger**: Receives and visualizes the trace data.
- **Tracing**: Rust's tracing library to generate spans.

You can add more spans or attributes within handlers for more detailed trace data.

Let me know if you'd like to explore advanced concepts like propagating context across microservices!
