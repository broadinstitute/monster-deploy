# Processing Project

This module will initialize all the infrastructure needed
to run a "processing" Monster project. So far, this includes:
1. Networks to run compute
2. A GKE master with no nodes, attached to the network
3. GCS buckets for storing project-specific artifacts and data

The GKE master is left nodeless to avoid racking up charges for
infrequently-run workflows. Ingest pipelines are responsible for
spinning the nodes they need up/down as part of their execution.
