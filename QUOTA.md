# Quotas

The following quotas can affect scaling.

## Google Cloud Platform

| Service                                  | Quota                    | Dimensions | Limit | Note                                                            |
|------------------------------------------|--------------------------|------------|-------|-----------------------------------------------------------------|
| Identity and Access Management (IAM) API | Service Account Count    |            | 100   | ✔️ We use one service account for all VMs.                      |
| Cloud Build API                          | Concurrent builds        |            | 30    | ✔️ All jobs are queued. 30 in parallel, then jobs have to wait. |
| Compute Engine API                       | Static IP addresses      | Region     | 700   | ⚠️ Seems to be the limiting factor.                             |
| Compute Engine API                       | In-use IP addresses      | Region     | 2300  | > 700 * e2-micro                                                |
| Compute Engine API                       | CPUs                     | Region     | 2400  | > 700 * e2-micro                                                |
| Compute Engine API                       | Persistent Disk SSD (GB) | Region     | 82 TB | > 700 * 25 GB                                                   |
| Cloud Scheduler API                      | Jobs                     | Region     | 5000  | > 700 VMs                                                       |

Source: [Google Cloud Console](https://console.cloud.google.com/iam-admin/quotas)

## Docker Hub

Docker Hub limits the number of Docker image downloads ("pulls") based on the account type of the user pulling the image.
Pull rates limits are based on individual IP address.
For anonymous users, the rate limit is set to **100 pulls per 6 hours** per IP address.

The Artifact Registry in the Google Cloud can be used to avoid this limit.

Source: [Docker Docs](https://docs.docker.com/docker-hub/download-rate-limit/#what-is-the-download-rate-limit-on-docker-hub)

## Paper

The length of the paper roll is limited.
There are rolls of different lengths:

* 9m
* 14m
* 25m

Take xtra large roll so you don't have to change as often.