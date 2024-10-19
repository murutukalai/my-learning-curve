```
// Lib - JwtSession

use chrono::{Duration, NaiveDateTime, Utc};
use serde::{Deserialize, Serialize};

use base::core::Result;
use cache_db::Conn;

#[derive(Debug, Deserialize, Serialize)]
pub struct SessionInfo {
    pub session_id: String,
    pub user_id: i64,
    pub device_id: String,
    pub expired_on: NaiveDateTime,
    pub is_active: bool,
}

pub async fn migration(db: &Conn) -> Result<()> {
    let mut conn = db.lock().await;
    conn.query_parse::<bool>(&cache_db::query!("CREATE SPACE IF NOT EXISTS apps"))?;

    conn.query_parse::<bool>(&cache_db::query!(
        "CREATE MODEL IF NOT EXISTS apps.session(
        session_id: string,
        user_id: uint64,
        device_id: string,
        expired_on: string,
        is_active: bool,
        null closed_on: string)"
    ))?;
    Ok(())
}

pub async fn create(db: &Conn, user_id: i64, device_id: &str, expiry: i64) -> Result<String> {
    let expired_on = (Utc::now() + Duration::minutes(expiry)).naive_utc();
    let session_id = uuid::Uuid::new_v4().to_string();
    let query = format!(
        "INSERT INTO apps.session {{ session_id: '{}', user_id: {}, device_id: '{}', expired_on: '{}', is_active: true, closed_on: null }}",
        &session_id,
        user_id,
        device_id,
        &expired_on.to_string(),
    );
    println!("{}", query);
    db.lock()
        .await
        .query_parse::<bool>(&cache_db::query!(query))?;
    println!("Created");

    Ok("49821661-91d3-4ef3-b434-3c4facaa6501".to_string())
}

pub async fn get_by_id(db: &Conn, session_id: &str) -> Result<(i64, String, String)> {
    let query = format!(
        "SELECT user_id, device_id, session_id FROM apps:session WHERE session_id = \"{}\" ",
        &session_id
    );
    println!("{}", query);
    let query = cache_db::query!(query);
    let (a, b, c) = db
        .lock()
        .await
        .query_parse::<(i64, String, String)>(&query)?;
    Ok((a, b.to_string(), c.to_string()))
}

pub async fn update_expiry(db: &Conn, session_id: &str, expiry: i64) -> Result<()> {
    let expired_on = (Utc::now() + Duration::minutes(expiry)).naive_utc();
    let query = cache_db::query!(
        "update apps.session SET expired_on = ? WHERE session_id = ?",
        &expired_on.to_string(),
        &session_id
    );
    db.lock().await.query_parse::<bool>(&query)?;
    println!("updated");
    Ok(())
}

pub async fn close(db: &Conn, session_id: &str) -> Result<()> {
    let closed_on = Utc::now().naive_utc();
    let query = cache_db::query!(
        "update apps.session SET closed_on = ?, is_active = ? WHERE id = ?",
        &closed_on.to_string(),
        &false,
        &session_id
    );
    let _: () = db.lock().await.query_parse(&query)?;
    println!("closed");
    Ok(())
}
```
