# Monster Deploy
Infrastructure-as-code for deploying Monster team's environments.

_Note_ - if you are using this to deploy HCA you need to [Setup Git Secrets](https://dsp-security.broadinstitute.org/platform-security-categories/git/setup-git-secrets)

## Before Contributing
1. Install [Terraform Security Check](https://aquasecurity.github.io/tfsec/v1.28.1/guides/installation/) `brew install tfsec`
2. Install [Github Pre-Commit Hooks](https://pre-commit.com/#install) `brew install pre-commit`
3. Run `pre-commit install` to install the pre-commit hooks
4. You can always run `pre-commit run --all-files` to run the pre-commit hooks manually
5. NB: You can also use `git commit -m "Skipped pre-commit hooks" --no-verify` to skip the pre-commit hooks

## Technologies used
We use [Terraform](https://www.terraform.io/docs/index.html) and
[Helm](https://helm.sh/docs/) to manage our deployments.

## Defining an environment.
See the [README](environments/README.md).

## Deploying an environment
See the [README](hack/README.md).

## Setting up Terra Resources
We can automate nearly all of our infrastructure setup, but not the creation of
resources in Terra (at least not yet). These actions require manual work:
1. Registering a Google service account with Terra
2. Creating a TDR resource profile
3. Creating a TDR dataset

NOTE: The instructions below use many APIs that are planned to change pretty
drastically as part of Terra's new architecture. Your milage may vary.

### Registering Accounts
Terraform can create Google SAs, but it can't register them in the Terra system.
We need to register the SAs that run our ingest pipelines in order to grant them
read/write permissions to the dataset(s) they target.

To register an account:
1. Apply the Terraform module that creates the account; it should also write the
   account's secret key to Vault
2. Read the secret key from Vault into a JSON file on your local machine
3. Run [the registration script](./hack/register-service-account), passing the path
   to the key-file and the name of the targeted Terra environment

After registering the account, you'll still need to grant it permissions. The easiest
way to do that right now is to make it a TDR steward. You can do this by:
1. Go to the Terra UI for the targeted environment
   * Dev: https://bvdp-saturn-dev.appspot.com/
   * Prod: https://app.terra.bio/
2. Click the top-left hamburger menu, then the dropdown with your name, then "Groups"
3. Find the Stewards group in the list of your groups
   * Dev: "JadeStewards-dev"
   * Prod: "Stewards"
4. Add the SA to the group using its email address
5. Grant access to relevant datasets by calling the Jade `addDatasetPolicyMember` with `policyName` = `steward` for the SA 
   in either [Dev](https://jade.datarepo-dev.broadinstitute.org/swagger-ui.html#/repository/addDatasetPolicyMember)
   or [Prod](https://jade-terra.datarepo-prod.broadinstitute.org/swagger-ui.html#/repository/addDatasetPolicyMember)
   (see [the Data repo FAQ](https://docs.google.com/document/d/1WDtW5TyX8Nwb0GkNxltmICCxj2qThQrDtMFkUW9K9l0))

### Creating Resource Profiles
Resource profiles connect Google Billing Accounts to the repository's machinery. You
should only need to create a new profile when a projects begins with a funding source
that hasn't been used before.

Step 1 of setting up a profile is ensuring the TDR can access the targeted account.
Grant the TDR's service account "Billing Account User" permissions on the account.
* Dev: jade-k8-sa@broad-jade-dev.iam.gserviceaccount.com
* Prod: terra-data-repository@broad-datarepo-terra-prod.iam.gserviceaccount.com
You need to be a Billing Account Administrator on the target account to make this change.

Step 2 is to get the ID of the Billing Account. If you're viewing the details page
of the BA, the ID is in the URL:
```
https://console.cloud.google.com/billing/{id}
```

Step 3 is to link the Billing Account into the TDR. Visit the Swagger UI of the TDR instance.
Under the "resources" section, expand the POST route. Click "Try it out" and make the following
edits to the pre-populated JSON:
1. Replace the value of "biller" with the constant string "direct"
2. Replace the value of "billingAccountId" with the ID from step 2
3. Replace the value of "profileName" with some unique name for the profile object; it will be
   used in the name of the generated GCP project

NOTE: When the TDR creates a project, it applies a prefix to the profile name. Google imposes
a character maximum on project names. This means that profile names are effectively length-
limited, but the limit depends on other configuration in the TDR. In the current production
deployment, the limit is 4 characters.

Once you've filled out the JSON, you can submit the POST. If everything works out, you should
get back the same payload with extra fields:
* An "accessible" field with a value of `true`
* An "id" field with a UUID

The UUID is needed for dataset creation.

### Creating Datasets
TDR Datasets are the main targets of our ingest pipelines. Most of the hard work that goes into
dataset creation involves schema design & declaration. Our [ingest-utils](https://github.com/DataBiosphere/ingest-utils)
repository includes tooling & build plugins to assist with that piece of the puzzle.

Pre-work:
1. Create a resource profile for the dataset
2. Declare the schema for the dataset in the ingest project, using our plugins

From there, step 1 is to generate the Jade-compatible definition of the schema. From the root
of the ingest project, run `sbt generateJadeSchema`. The output should include a line:
```
[info] Wrote Jade schema to <some-path>/schema.json
```

Step 2 is to declare the dataset. Visit the Swagger UI of the TDR instance.
Under the "repository" section, look for the POST `/api/repository/v1/datasets` route.
Expand it, click "Try it out", and make the following edits to the pre-populated JSON:
1. Delete the "additionalProfileIds" field
2. Replace the value of "defaultProfileId" with the UUID of the resource profile you want to use
3. Replace the value of "description" with whatever you'd like, or delete it
4. Replace the value of "name" with a BigQuery-compatible identifier (only lowercase alphanumeric characters and '_' allowed)
5. Replace the entire value of "schema" with the contents of the Jade schema generated
   by `sbt` in step 1

Once you've filled out the JSON, you can submit the POST. You'll get back a job ID.

Step 3 is to poll the job ID until it finishes. You can do so using the GET `/api/repository/v1/jobs/{id}`
route in the Swagger UI. When the job exits the "running" state, you can get its final results using
the GET `/api/repository/v1/jobs/{id}/result` endpoint. For succeeded jobs, this call will output
the ID of the new dataset. For failed jobs, this call will show information about what went wrong.
