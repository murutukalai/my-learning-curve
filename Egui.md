To integrate `egui` with `axum`, we can use the `axum` framework for server-side handling and `egui` as the GUI library on the client side. Since `egui` runs on WebAssembly for web-based applications, we will leverage the `wasm-bindgen` crate to allow `egui` to compile to WebAssembly, making it runnable in a browser. Below is an example setup.

### Step 1: Set up the Rust Project

Create a new Rust project with:

```bash
cargo new axum_egui_example
cd axum_egui_example
```

Add the required dependencies in your `Cargo.toml`:

```toml
[dependencies]
axum = "0.6"
tokio = { version = "1", features = ["full"] }
hyper = "0.14"
tower = "0.4"

# For WebAssembly and `egui`
wasm-bindgen = "0.2"
egui = "0.18"
```

To work with WebAssembly, you'll need to add additional targets for Rust. You can do this by running:

```bash
rustup target add wasm32-unknown-unknown
```

### Step 2: Set Up the Server with Axum

In your `src/main.rs`, create a simple Axum server to serve static files and handle API requests:

```rust
use axum::{routing::get, Router};
use std::net::SocketAddr;
use tower_http::services::ServeDir;

#[tokio::main]
async fn main() {
    // Create a router to serve static files
    let app = Router::new()
        .nest_service("/", ServeDir::new("./static"))
        .route("/api", get(|| async { "Hello from API" }));

    // Specify the address
    let addr = SocketAddr::from(([127, 0, 0, 1], 8080));
    println!("Listening on {}", addr);

    // Start the server
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}
```

This example uses `ServeDir` from `tower-http` to serve static files from the `./static` directory, which we’ll create in the next step.

### Step 3: Set Up `egui` with WebAssembly

Now, let’s create a simple `egui` application that can run in the browser. Inside your project directory, create a new folder called `static`, and add a file called `index.html` with the following content:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>egui with axum</title>
</head>
<body>
    <h1>Welcome to egui with Axum</h1>
    <div id="egui_canvas"></div>
    <script type="module">
        import init from './pkg/axum_egui_example.js';
        init();
    </script>
</body>
</html>
```

### Step 4: Create the WebAssembly Module

Now we’ll create the `egui` app that will run in WebAssembly. In your `src` folder, add a new file called `lib.rs`:

```rust
use wasm_bindgen::prelude::*;
use egui::{CentralPanel, Context};

#[wasm_bindgen(start)]
pub fn start() -> Result<(), JsValue> {
    // Start the eframe (egui) application
    eframe::start_web("egui_canvas", Box::new(MyApp::default()))
}

// Define a simple egui application
struct MyApp;

impl eframe::App for MyApp {
    fn update(&mut self, ctx: &Context, _: &mut eframe::Frame) {
        CentralPanel::default().show(ctx, |ui| {
            ui.label("Hello from egui!");
            if ui.button("Click me").clicked() {
                ui.label("Button clicked!");
            }
        });
    }
}
```

In this file, we define a `MyApp` struct implementing `eframe::App`. The `update` function displays a label and a button, and when the button is clicked, it updates the interface.

### Step 5: Compile the WebAssembly and Run

Run the following command to build the WebAssembly module:

```bash
wasm-pack build --target web
```

This will generate a `pkg` folder with the WebAssembly files. Move these files to the `static` directory.

### Step 6: Run the Server

Finally, start the server:

```bash
cargo run
```

Now, navigate to `http://localhost:8080` in your browser to see your `egui` application running inside an `Axum` server.

This setup provides a basic starting point for using `egui` with `axum`.
