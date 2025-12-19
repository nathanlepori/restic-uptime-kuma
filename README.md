# Restic Uptime Kuma

This project provides a monitoring solution for Restic backups using Uptime Kuma push monitors. **It currently only supports S3 based backups.**

## Usage

First create a push monitor on Uptime Kuma and set the heartbeat to the desired interval to check for a heartbeat, for example 86400 seconds or 24 hours. Note down the push URL.

To run the monitoring service, you can use Docker Compose. Make sure you have Docker and Docker Compose installed on your machine.

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd restic-uptime-kuma
   ```

2. Create a `.env` file in the root directory with the following required variables:
   ```dotenv
   # Required environment variables
   PUSH_BASE_URL=<your_push_base_url>
   INTERVAL=<your_interval>
   AWS_ACCESS_KEY_ID=<your_aws_access_key_id>
   AWS_SECRET_ACCESS_KEY=<your_aws_secret_access_key>
   RESTIC_PASSWORD=<your_restic_password>
   ```

3. Start the services using Docker Compose:
   ```bash
   docker-compose up
   ```

## Required Variables

- `PUSH_BASE_URL`: The Uptime Kuma push URL **without query parameters**.
- `INTERVAL`: Heartbeat interval in seconds. Must be shorter than the interval set in Uptime Kuma to avoid missed heartbeats. Default: 43200 (12 hours)
- `AWS_ACCESS_KEY_ID`: Your Restic repository S3 access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your Restic repository S3 secret access key.
- `RESTIC_PASSWORD`: The password for your Restic repository.

Make sure to replace the placeholder values in the `.env` file with your actual configuration values.