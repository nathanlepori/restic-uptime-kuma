FROM restic/restic:latest

# Install required packages
RUN apk add --no-cache curl
RUN apk add --no-cache bash

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Override the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
