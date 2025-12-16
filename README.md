# Docker Swarm Visualizer

A real-time web visualization tool for Docker Swarm clusters. See your nodes, services, and networks as an interactive graph.

## Demo

A live demo is available at: https://sammonsempes.github.io/DockerSwarmVisualizer/

** Generating Docker Swarm Data **

To generate the JSON data from your Docker Swarm cluster, run the following command:
```bash
jq -n \
  --slurpfile n <(docker node ls --format '{{json .}}' | jq -s .) \
  --slurpfile net <(docker network ls --filter scope=swarm -q | xargs -r docker network inspect) \
  --slurpfile s <(docker service ls -q | xargs -r docker service inspect | jq -s 'flatten') \
  --slurpfile tasks <(docker service ls -q | xargs -r -I {} docker service ps {} --format '{{json .}}' -f "desired-state=running" | jq -s .) \
'
{
  nodes: $n[0] | map({
    id: .ID,
    hostname: .Hostname,
    status: .Status,
    availability: .Availability,
    role: (.ManagerStatus // "worker")
  }),
  networks: $net[0] | map({
    id: .Name,
    name: .Name,
    driver: .Driver,
    scope: .Scope,
    created: .Created,
    ipam: .IPAM
  }),
  services: $s[0] | map({
    id: .Spec.Name,
    name: .Spec.Name,
    mode: (.Spec.Mode | keys[0]),
    replicas: "\((.Spec.Mode.Replicated.Replicas // 1))/\((.Spec.Mode.Replicated.Replicas // 1))",
    image: (.Spec.TaskTemplate.ContainerSpec.Image | split("@")[0]),
    networks: [.Spec.TaskTemplate.Networks // [] | .[] | . as $target | $net[0][] | select(.Id == $target.Target).Name],
    runningOn: (.Spec.Name as $svc | [$tasks[0][] | select(.Name | startswith($svc + ".")) | .Node] | unique),
    ports: [.Endpoint.Ports // [] | .[] | "\(.PublishedPort):\(.TargetPort)/\(.Protocol)"],
    mounts: [.Spec.TaskTemplate.ContainerSpec.Mounts // [] | .[] | "\(.Source):\(.Target)"],
    constraints: [.Spec.TaskTemplate.Placement.Constraints // [] | .[]],
    labels: (.Spec.Labels // {})
  })
}
' | jq -c
```

**Prerequisites:**
- Docker Swarm must be initialized and running
- `jq` must be installed
- You must be on a swarm manager

**Usage:**
Copy the generated JSON output and paste it into the visualizer's input field.

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
git clone https://github.com/sammonsempes/DockerSwarmVisualizer.git
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
