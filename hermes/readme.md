Running in gateway mode
https://hermes-agent.nousresearch.com/docs/user-guide/docker
Once configured, run the container in the background as a persistent gateway (Telegram, Discord, Slack, WhatsApp, etc.):

docker run -d \
  --name hermes \
  --restart unless-stopped \
  -v ~/.hermes:/opt/data \
  -p 8642:8642 \
  nousresearch/hermes-agent gateway run

Port 8642 exposes the gateway's OpenAI-compatible API server and health endpoint. It's optional if you only use chat platforms (Telegram, Discord, etc.), but required if you want the dashboard or external tools to reach the gateway.

Note: the API server is gated on API_SERVER_ENABLED=true. To expose it beyond 127.0.0.1 inside the container, also set API_SERVER_HOST=0.0.0.0 and an API_SERVER_KEY (minimum 8 characters; generate one with `openssl rand -hex 32`). Keep the key in `hermes/.env`, which is ignored by Git:

```env
API_SERVER_KEY=replace_with_generated_key
```

Example:

docker run -d \
  --name hermes \
  --restart unless-stopped \
  -v ~/.hermes:/opt/data \
  -p 8642:8642 \
  --env-file hermes/.env \
  -e API_SERVER_ENABLED=true \
  -e API_SERVER_HOST=0.0.0.0 \
  -e API_SERVER_CORS_ORIGINS='*' \
  nousresearch/hermes-agent gateway run

Opening any port on an internet facing machine is a security risk. You should not do it unless you understand the risks.
Running the dashboard

The built-in web dashboard runs as an optional side-process inside the same container as the gateway. Set HERMES_DASHBOARD=1 and expose port 9119 alongside the gateway's 8642:

docker run -d \
  --name hermes \
  --restart unless-stopped \
  -v ~/.hermes:/opt/data \
  -p 8642:8642 \
  -p 9119:9119 \
  -e HERMES_DASHBOARD=1 \
  nousresearch/hermes-agent gateway run

Once configured, run the container in the background as a persistent gateway (Telegram, Discord, Slack, WhatsApp, etc.):

docker run -d \
  --name hermes \
  --restart unless-stopped \
  -v ~/.hermes:/opt/data \
  -p 8642:8642 \
  nousresearch/hermes-agent gateway run

Port 8642 exposes the gateway's OpenAI-compatible API server and health endpoint. It's optional if you only use chat platforms (Telegram, Discord, etc.), but required if you want the dashboard or external tools to reach the gateway.

Note: the API server is gated on API_SERVER_ENABLED=true. To expose it beyond 127.0.0.1 inside the container, also set API_SERVER_HOST=0.0.0.0 and an API_SERVER_KEY (minimum 8 characters; generate one with `openssl rand -hex 32`). Keep the key in `hermes/.env`, which is ignored by Git:

```env
API_SERVER_KEY=replace_with_generated_key
```

Example:

docker run -d \
  --name hermes \
  --restart unless-stopped \
  -v ~/.hermes:/opt/data \
  -p 8642:8642 \
  --env-file hermes/.env \
  -e API_SERVER_ENABLED=true \
  -e API_SERVER_HOST=0.0.0.0 \
  -e API_SERVER_CORS_ORIGINS='*' \
  nousresearch/hermes-agent gateway run

Opening any port on an internet facing machine is a security risk. You should not do it unless you understand the risks.
Running the dashboard

The built-in web dashboard runs as an optional side-process inside the same container as the gateway. Set HERMES_DASHBOARD=1 and expose port 9119 alongside the gateway's 8642:

docker run -d \
  --name hermes \
  --restart unless-stopped \
  -v ~/.hermes:/opt/data \
  -p 8642:8642 \
  -p 9119:9119 \
  -e HERMES_DASHBOARD=1 \
  nousresearch/hermes-agent gateway run
