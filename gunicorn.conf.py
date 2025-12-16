# Bind
bind = "0.0.0.0:5000"

# Workers
workers = 1
worker_class = "sync"
threads = 2

# Timeout
timeout = 30
keepalive = 5

# Logging
accesslog = "-"
errorlog = "-"
loglevel = "info"

# Security
limit_request_line = 4094
limit_request_fields = 100
