To implement **Jaeger logging** using **tracing** in Rust, you can utilize the `tracing` ecosystem with the `tracing-opentelemetry` crate, which bridges the gap between `tracing` and OpenTelemetry. OpenTelemetry can then export traces to **Jaeger**.

Here’s a step-by-step guide to implementing Jaeger tracing in Rust:

---

### **Dependencies**
Add the necessary dependencies to your `Cargo.toml`:

```toml
[dependencies]
tokio = { version = "1", features = ["full"] }
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
tracing-opentelemetry = "0.22"
opentelemetry = { version = "0.22", features = ["rt-tokio"] }
opentelemetry-jaeger = { version = "0.22", features = ["rt-tokio"] }
```

---

### **Code Example**

Below is an implementation example for integrating **Jaeger** with **tracing**:

```rust
use opentelemetry::global;
use opentelemetry::sdk::propagation::TraceContextPropagator;
use opentelemetry::sdk::trace::{self, Sampler};
use opentelemetry::runtime::Tokio;
use tracing::{info, span, Level};
use tracing_subscriber::layer::SubscriberExt;
use tracing_subscriber::Registry;
use tracing_opentelemetry::OpenTelemetryLayer;

// Initialize OpenTelemetry tracing with Jaeger
fn init_tracer() -> opentelemetry::sdk::trace::Tracer {
    opentelemetry_jaeger::new_pipeline()
        .with_service_name("rust-jaeger-example")
        .with_trace_config(trace::config().with_sampler(Sampler::AlwaysOn)) // Always sample for demo
        .install_batch(Tokio) // Use batch exporter with Tokio runtime
        .expect("Failed to initialize tracer")
}

#[tokio::main]
async fn main() {
    // Setup OpenTelemetry propagator
    global::set_text_map_propagator(TraceContextPropagator::new());

    // Initialize OpenTelemetry tracer
    let tracer = init_tracer();

    // Set up tracing-subscriber with OpenTelemetry layer
    let telemetry_layer = OpenTelemetryLayer::new(tracer);
    let subscriber = Registry::default()
        .with(tracing_subscriber::fmt::layer()) // Logs to stdout
        .with(telemetry_layer);

    tracing::subscriber::set_global_default(subscriber)
        .expect("Failed to set subscriber");

    // Example spans and logging
    let root_span = span!(Level::INFO, "main_span", work = "example");
    let _enter = root_span.enter();

    info!("Application starting up...");

    // Simulate work
    perform_work().await;

    info!("Application shutting down...");

    // Ensure all spans are exported before shutdown
    global::shutdown_tracer_provider();
}

// Simulate some async work
async fn perform_work() {
    let span = span!(Level::INFO, "work_span", task = "work simulation");
    let _enter = span.enter();

    info!("Performing some work...");
    tokio::time::sleep(tokio::time::Duration::from_secs(2)).await;
    info!("Work complete!");
}
```

---

### **Steps in the Code**

1. **Dependencies**: The example uses `tokio` for asynchronous execution, `tracing` for structured logging, and `opentelemetry-jaeger` for exporting spans to Jaeger.
   
2. **Tracer Initialization**:
   - `opentelemetry_jaeger::new_pipeline()` creates a pipeline to send spans to Jaeger.
   - `install_batch()` enables asynchronous exporting using the Tokio runtime.

3. **Tracing Subscriber**:
   - `tracing-subscriber` integrates OpenTelemetry into the `tracing` system.
   - `tracing_opentelemetry::OpenTelemetryLayer` is added to the subscriber.

4. **Creating Spans**:
   - Use `span!()` or `info!()` to log messages and create tracing spans.

5. **Shutdown**:
   - Call `global::shutdown_tracer_provider()` to flush all spans to Jaeger before the application exits.

---

### **Run Jaeger Locally**

1. Start Jaeger using Docker:
   ```bash
   docker run -d --name jaeger \
       -e COLLECTOR_ZIPKIN_HTTP_PORT=9411 \
       -p 5775:5775/udp \
       -p 6831:6831/udp \
       -p 6832:6832/udp \
       -p 5778:5778 \
       -p 16686:16686 \
       -p 14268:14268 \
       -p 14250:14250 \
       -p 9411:9411 \
       jaegertracing/all-in-one:latest
   ```

2. Run your Rust application:
   ```bash
   cargo run
   ```

3. Access Jaeger UI at [http://localhost:16686](http://localhost:16686).

---

### **Output**

- Traces created by your application will appear in Jaeger under the service name `rust-jaeger-example`.
- You will see spans, timing details, and logs structured in the UI.

This setup integrates Jaeger for tracing using the powerful `tracing` and OpenTelemetry ecosystem. You can now observe spans and logs in Jaeger for debugging and performance monitoring.
_________
To integrate **Jaeger tracing** into an **Axum server** using `tracing` and `OpenTelemetry`, you need to hook the tracing infrastructure into Axum's router and request handling. Here's a complete example:

---

### **Dependencies**

Add the following to your `Cargo.toml`:

```toml
[dependencies]
axum = "0.6"                       # Web framework
tokio = { version = "1", features = ["full"] } # Async runtime
tracing = "0.1"                    # Logging and spans
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
tracing-opentelemetry = "0.22"
opentelemetry = { version = "0.22", features = ["rt-tokio"] }
opentelemetry-jaeger = { version = "0.22", features = ["rt-tokio"] }
```

---

### **Code Example**

Here's how to integrate Jaeger tracing with an **Axum** server:

```rust
use axum::{routing::get, Router};
use opentelemetry::global;
use opentelemetry::sdk::propagation::TraceContextPropagator;
use opentelemetry::sdk::trace::{self, Sampler};
use opentelemetry::runtime::Tokio;
use std::net::SocketAddr;
use tracing::{info, Level};
use tracing_subscriber::layer::SubscriberExt;
use tracing_subscriber::Registry;
use tracing_opentelemetry::OpenTelemetryLayer;

// Initialize OpenTelemetry with Jaeger backend
fn init_tracer() -> opentelemetry::sdk::trace::Tracer {
    opentelemetry_jaeger::new_pipeline()
        .with_service_name("axum-jaeger-example")
        .with_trace_config(trace::config().with_sampler(Sampler::AlwaysOn)) // Always sample for demo
        .install_batch(Tokio)
        .expect("Failed to initialize tracer")
}

// Axum handler function
async fn root_handler() -> &'static str {
    let span = tracing::span!(Level::INFO, "handler_span", work = "root_handler");
    let _enter = span.enter();

    info!("Handling request to /");
    "Hello, World!"
}

#[tokio::main]
async fn main() {
    // Set up OpenTelemetry propagator
    global::set_text_map_propagator(TraceContextPropagator::new());

    // Initialize the OpenTelemetry tracer
    let tracer = init_tracer();

    // Set up tracing-subscriber with OpenTelemetry layer
    let telemetry_layer = OpenTelemetryLayer::new(tracer);
    let subscriber = Registry::default()
        .with(tracing_subscriber::fmt::layer()) // Logs to stdout
        .with(telemetry_layer);

    tracing::subscriber::set_global_default(subscriber)
        .expect("Failed to set tracing subscriber");

    // Create Axum router
    let app = Router::new()
        .route("/", get(root_handler));

    // Start Axum server
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    info!("Listening on http://{}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();

    // Flush and shutdown the tracer
    global::shutdown_tracer_provider();
}
```

---

### **Explanation**

1. **Tracer Initialization**:
   - `init_tracer()` sets up the Jaeger exporter for OpenTelemetry.
   - The `Sampler::AlwaysOn` ensures all requests are traced.

2. **`tracing-subscriber` Integration**:
   - The `OpenTelemetryLayer` is added to the tracing subscriber to forward spans to Jaeger.

3. **Axum Handler**:
   - Tracing spans are created within the handler using `tracing::span!`.
   - Logs and spans are automatically propagated and collected.

4. **Server Initialization**:
   - Axum binds the router to `127.0.0.1:3000`.

5. **Shutdown**:
   - `global::shutdown_tracer_provider()` ensures all traces are flushed before the server exits.

---

### **Run and Test**

1. **Start Jaeger**:
   ```bash
   docker run -d --name jaeger \
       -p 6831:6831/udp -p 16686:16686 \
       jaegertracing/all-in-one:latest
   ```

2. **Run the Server**:
   ```bash
   cargo run
   ```

3. **Access the Endpoint**:
   Open `http://127.0.0.1:3000` in your browser or use `curl`:
   ```bash
   curl http://127.0.0.1:3000
   ```

4. **View Traces**:
   Go to the Jaeger UI at [http://localhost:16686](http://localhost:16686) and search for the service `axum-jaeger-example`. You'll see traces for each request.

---

### **Output**

- Tracing spans will appear in the Jaeger UI, showing the span for each incoming HTTP request and any internal spans you’ve created (like `handler_span`).

By integrating tracing with Axum, you gain observability for your web server, enabling performance monitoring, debugging, and distributed tracing across microservices.
