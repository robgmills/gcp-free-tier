# GCP Free Tier
Terraform modules that provisions cloud resources within the Google Cloud Platform (GCP) Free Tier limits.  

**DISCLAIMER:** The author of this project does not guarantee that you will not incur charges with GCP if you use this project.

## Prerequisites

Create a GCP account and project at https://console.cloud.google.com.

In that project, creat a _Service Account_ for the project with the following roles attached:

- _Compute Public IP Admin_
- _Compute Instance Admin_
- _Compute Network Admin_
- _Compute Security Admin_
- _Monitoring Admin_

## Required Terraform credentials/environment variables
Set the following environment variables for the `google` Terraform provider:

- `GOOGLE_REGION` - Must be one of `us-west1`, `us-central1`, `us-east1` to fall within the [free tier limit requirements](https://cloud.google.com/free/docs/gcp-free-tier#free-tier-usage-limits).  Choose whichever is physically closest to you.
- `GOOGLE_PROJECT` - Your Google Cloud Platform project id.
- `GOOGLE_CREDENTIALS` - Contents of a [service account key file](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) in JSON format. You can [manage key files using the Cloud Console](https://console.cloud.google.com/apis/credentials/serviceaccountkey). [See the full reference for more details](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#full-reference).

## Full Example

See [`examples.tf`](./examples.tf) for example implementations of all the modules.

In addition to the environment variables listed above, the examples expect the following env vars:

- `TF_VAR_GCE_ZONE`
- `TF_VAR_SSH_PUBKEY_FILE`
- `TF_VAR_SSH_USER`

## Modules

### Compute

Provisions an `f1-micro` Google Compute Cloud instance that can run 24x7 while not incurring charges.  Be aware that there are data transfer limits in order to stay in the free tier.

This instance has firewall rules that allow inbound traffic for SSH (port 22), HTTP/HTTPS (ports 80 and 443), and DNS (port 53)

This module requires the following variables provided to it:

- `gce_zone` - A zone in the region you've configured in `GOOGLE_REGION`; usually `${GOOGLE_REGION}-a` (or `-b` or `-c`).
- `gce_ssh_pubkey_file` - A public SSH key used to connect to the instance
- `gce_ssh_user` - Your SSH user