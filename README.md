# GCP Free Tier
Terraform that provisions cloud resources within the Google Cloud Platform (GCP) Free Tier limits.  

**DISCLAIMER:** The author of this project does not guarantee that you will not incur charges with GCP if you use this project.

## Prerequisites

Create a GCP account and project at https://console.cloud.google.com.

In that project, creat a _Service Account_ for the project with the following roles attached:

- _Compute Public IP Admin_
- _Compute Instance Admin_
- _Compute Network Admin_
- _Compute Security Admin_

## Required Terraform credentials/environment variables
Set the following environment variables for the `google` Terraform provider:

- `GOOGLE_REGION` - Must be one of `us-west1`, `us-central1`, `us-east1` to fall within the [free tier limit requirements](https://cloud.google.com/free/docs/gcp-free-tier#free-tier-usage-limits).  Choose whichever is physically closest to you.
- `GOOGLE_PROJECT` - Your Google Cloud Platform project id.
- `GOOGLE_CREDENTIALS` - Contents of a [service account key file](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) in JSON format. You can [manage key files using the Cloud Console](https://console.cloud.google.com/apis/credentials/serviceaccountkey). [See the full reference for more details](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#full-reference).
- `TF_VAR_google_zone` - A zone in the region you've configured in `GOOGLE_REGION`
- `TF_VAR_gce_ssh_pubkey_file` - A public SSH key used to connect to the instance
- `TF_VAR_gce_ssh_user` - Your SSH user