use std::{
    fmt::Debug,
    net::TcpStream,
    sync::Arc,
    thread::{self, sleep, JoinHandle},
    time::Duration,
};

use serde::{Deserialize, Serialize};
use tokio::sync::Mutex;
use tokio_tungstenite::connect_async;
use tungstenite::{
    connect, http::Uri, stream::MaybeTlsStream, ClientRequestBuilder, Error, Message, WebSocket,
};
use uniffi::deps::log;

uniffi::setup_scaffolding!();

#[derive(Serialize, Deserialize, Debug, uniffi::Record)]
pub struct TaskItem {
    pub id: i64,
    pub created_on: String,
    pub title: String,
    pub tags: Vec<String>,
    pub description: String,
    pub is_done: bool,
}

#[derive(Debug, uniffi::Object, Clone)]
pub struct WsClient {
    url: String,
    base_url: String,
    status_callback: Option<Arc<dyn StatusCallback>>,
    status: Arc<Mutex<String>>,
    ping_thread: Option<Arc<Mutex<JoinHandle<()>>>>,
}

#[uniffi::export(with_foreign)]
pub trait StatusCallback: Send + Sync + Debug {
    fn on_change(&self, status: String) -> String;
}

impl WsClient {
    fn new(url: String) -> WsClient {
        Self {
            url,
            base_url: String::new(),
            status_callback: None,
            status: Arc::new(Mutex::new("stopped".to_string())),
            ping_thread: None,
        }
    }

    fn set_url(&mut self, url: String) {
        self.base_url = url;
    }

    async fn start(&mut self) {
        let client = self.clone();

        if let Ok((mut conn, _)) = connect_async(client.url) {
            self.ping_thread = Some(tokio::spawn(async move {
                loop {
                    if let Err(err) = conn.send(Message::Ping(vec![])) {
                        match err {
                            Error::AlreadyClosed => {
                                client.change_status("disconnected".to_string()).await;
                                break;
                            }
                            Error::ConnectionClosed => {
                                client.change_status("disconnected".to_string()).await;
                                break;
                            }
                            _ => {
                                client.change_status("disconnected".to_string()).await;
                                log::error!("Error occurred while sending ping: {:?}", err);
                                break;
                            }
                        };
                    }
                    sleep(Duration::from_secs(30));
                }
            }));
        }
    }

    async fn stop(&mut self) {
        // if let Some(ref mut socket) = self.socket {
        //     if let Err(err) = socket.close(None) {
        //         log::error!("Error occurred while sending the close: {:?}", err)
        //     };
        // }

        self.change_status("stopped".to_string()).await;
    }

    fn set_status_callback(&mut self, status_callback: Arc<dyn StatusCallback>) {
        self.status_callback = Some(status_callback);
    }

    fn request(&mut self, request: String) -> String {
        // let Some(ref mut conn) = self.socket else {
        //     return String::new();
        // };

        // if let Err(err) = conn.send(tungstenite::Message::Text(request)) {
        //     log::error!("Error occurred while sending the request: {:?}", err);
        // }

        // if let Ok(msg) = conn.read() {
        //     return match msg {
        //         Message::Text(text) => text,
        //         _ => String::new(),
        //     };
        // }
        String::new()
    }

    async fn change_status(&self, input: String) {
        let mut status = self.status.lock().await;
        *status = input;
        self.notify_status().await;
    }

    async fn notify_status(&self) {
        if let Some(ref callback) = self.status_callback {
            callback.on_change(self.status.lock().await.clone());
        }
    }
}

#[derive(Debug, uniffi::Object)]
pub struct WsManager {
    ws_client: Arc<Mutex<WsClient>>,
}

#[uniffi::export]
impl WsManager {
    #[uniffi::constructor]
    fn new(url: String) -> Self {
        Self {
            ws_client: Arc::new(Mutex::new(WsClient::new(url))),
        }
    }

    pub async fn set_url(&self, url: String) {
        let mut client = self.ws_client.lock().await;
        client.set_url(url);
    }

    pub async fn start(&self) {
        let mut client = self.ws_client.lock().await;
        client.start().await;
    }

    pub async fn stop(&self) {
        let mut client = self.ws_client.lock().await;
        client.stop().await;
    }

    pub async fn send_request(&self, request: String) -> String {
        let mut client = self.ws_client.lock().await;
        client.request(request)
    }

    pub async fn notify_status(&self, notify_status: Arc<dyn StatusCallback>) {
        let mut client = self.ws_client.lock().await;
        client.set_status_callback(notify_status);
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[tokio::test]
    async fn test_ws_manger() {
        let manager = WsManager::new("ws://localhost:4800/ws".to_string());
        manager.set_url("http:localhost:4800".to_string()).await;
        manager.start().await;
        sleep(Duration::from_secs(10));
        manager.stop().await;
    }
}
