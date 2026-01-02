# Use the official rclone image
FROM rclone/rclone:latest

# Install fuse3 (required for mounting)
# The rclone image is based on Alpine Linux
RUN apk add --no-cache fuse3

# Create the mount point and config directory
RUN mkdir -p /data/sync_service /config/rclone

# Set the environment variables (you can change these later)
ENV USER_ID=1000
ENV GROUP_ID=1000

# The command to run when the container starts
# We use root inside the container to avoid the fusermount errors
ENTRYPOINT rclone mount ${REMOTE_NAME}: /data/sync_service \
    --config /config/rclone/rclone.conf \
    --drive-root-folder-id ${FOLDER_ID} \
    --vfs-cache-mode full \
    --cache-dir /config/rclone/vfs_cache \
    --allow-other \
    --uid ${USER_ID} \
    --gid ${GROUP_ID} \
    --dir-cache-time 10s \
    -vv
