# Docker Swarm Visualizer

A real-time web visualization tool for Docker Swarm clusters. See your nodes, services, and networks as an interactive graph.

## Demo

A live demo is available at: https://sammonsempes.github.io/DockerSwarmVisualizer/

## Features

- **Live visualization** - Interactive D3.js force-directed graph
- **Auto-detection** - Automatically loads Swarm data if available, falls back to demo mode
- **Real-time refresh** - Update data without page reload
- **Search** - Find nodes, services, and networks instantly
- **Detailed tooltips** - View replicas, ports, mounts, constraints, labels
- **Zoom & pan** - Navigate large clusters easily
- **Production-ready** - Gunicorn WSGI server included

## Quick Start

```bash
git clone https://github.com/DockerSwarmVisualizer/DockerSwarmVisualizer.git
cd DockerSwarmVisualizer
docker stack deploy -c docker-compose.yml visualizer
```

Open http://localhost:5000

## API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Web interface |
| `/api/swarm` | GET | JSON data |

### Response Format

```json
{
  "data": {
    "nodes": [
      {
        "id": "abc123",
        "hostname": "manager-01",
        "role": "Leader",
        "status": "Ready",
        "availability": "Active"
      }
    ],
    "networks": [
      {
        "id": "ingress",
        "name": "ingress",
        "driver": "overlay",
        "scope": "swarm"
      }
    ],
    "services": [
      {
        "id": "web",
        "name": "web",
        "image": "nginx:latest",
        "replicas": "3/3",
        "mode": "Replicated",
        "networks": ["ingress"],
        "ports": ["80:80/tcp"],
        "runningOn": ["manager-01", "worker-01"]
      }
    ]
  },
  "is_live": true
}
```

## Legend

| Color | Element |
|-------|---------|
| 🟢 Green | Manager node |
| 🔵 Blue | Worker node |
| 🟠 Orange | Service |
| 🔴 Red | Network |

## Requirements

- Docker with Swarm mode enabled

## Troubleshooting

**"Cannot connect to Docker: permission denied"**
- Ensure the Docker socket is mounted correctly
- Check socket permissions: `stat -c '%g' /var/run/docker.sock`

**"Docker Swarm not active"**
- Verify the service runs on a manager: `docker service ps visualizer`

**Demo data showing instead of live data**
- Check logs: `docker service logs visualizer`
- Verify constraint: `docker service inspect visualizer --pretty`
