https://courses.mooc.fi/org/uh-cs/courses/devops-with-kubernetes/

execute sh bin/bash/exXXX.sh from this folder to perform the exercises

Ex 3.9: Comparison between:
(a) Using a managed Database as a Service (DBaaS) (e.g., Google Cloud SQL),
(b) Running your own PostgreSQL on Kubernetes with PersistentVolumeClaims (PVCs) on Google Kubernetes Engine (GKE).

| Category                   | **Cloud SQL (DBaaS)**                               | **PostgreSQL on GKE with PVCs**      |
| -------------------------- | --------------------------------------------------- | ------------------------------------ |
| **Initial Setup**          | Very low effort                                     | Moderate to high effort              |
| **Ongoing Maintenance**    | Minimal (managed)                                   | High (you’re responsible)            |
| **Operational Complexity** | Low                                                 | High                                 |
| **Reliability**            | Very high (SLA + managed backups)                   | Depends on your config               |
| **Scalability**            | Easy vertical/horizontal scaling (with limitations) | Flexible but manual                  |
| **Backups**                | Built-in & easy                                     | Manual setup (tools, cron, operator) |
| **Cost**                   | Predictable; may be higher for heavy workloads      | Potentially cheaper at scale         |
| **Performance Control**    | Limited tuning                                      | Full control                         |
| **Security**               | Managed security, IAM                               | You’re responsible                   |
| **Cloud Integration**      | Deep, first-class                                   | Needs manual wiring                  |

Generated with this LLM prompt:
Do a pros/cons comparison, in terms of meaningful differences, between: a) using a Database as a Service (DBaaS) such as the Google Cloud SQL, or b) using PersistentVolumeClaims with our own Postgres images and let the Google Kubernetes Engine take care of storage via PersistentVolumes. Please include in the comparison at least the required work and costs to initialize as well as the maintenance. Backup methods and their ease of usage should be considered as well.
