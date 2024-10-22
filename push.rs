use apalis::prelude::TaskId;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
struct RedisJob<J> {
    ctx: Context,
    job: J,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
struct Context {
    id: TaskId,
    attempts: usize,
}

async fn push(conn: &mut conn, name: &str) -> Result<TaskId, RedisError> {
    let mut conn = self.conn.clone();
    let push_job = redis::Script::new(include_str!("./push_job.lua"));
    let job_data_hash = format!("{name}:data");
    let active_jobs_list = format!("{name}:active");
    let signal_list = format!("{name}:signal");
    let job_id = TaskId::new();
    let ctx = Context {
        attempts: 0,
        id: job_id.clone(),
    };
    let job = self.codec.encode(&RedisJob { ctx, job }).unwrap();
    push_job
        .key(job_data_hash)
        .key(active_jobs_list)
        .key(signal_list)
        .arg(job_id.to_string())
        .arg(job)
        .invoke_async(&mut conn)
        .await?;
    Ok(job_id.clone())
}
