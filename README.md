# tfe-dev-aws-instance
This repo contains a minimal TF configuration that can spin up a TFE instance for testing purpose. It's mainly used by the TF-Nexus team. 

## Steps
- Push AWS credentials to the [tfe-dev-aws-instance](https://app.terraform.io/app/tf-vcs-testing/workspaces/tfe-dev-aws-instance) workspace by 
  ```
  doormat login && doormat aws tf-push --account team_tf_vcs_dev --organization tf-vcs-testing --workspace tfe-dev-aws-instance
  ```
- Trigger a run to start the AWS instance in the [tfe-dev-aws-instance](https://app.terraform.io/app/tf-vcs-testing/workspaces/tfe-dev-aws-instance) workspace
- Once the apply finishes, visit the TFE console from the `tfe_console_url` output
- Continue to step 5 in the [guide](https://hashicorp.atlassian.net/wiki/spaces/IPL/pages/2617377324/Building+TFE+for+development+testing#Building-TFE-without-a-certificate-or-DNS) to set up the TFE instance
- Once you're done with the instance, [queue a destroy plan](https://app.terraform.io/app/tf-vcs-testing/workspaces/tfe-dev-aws-instance/settings/delete) to remove the instance

## (Optional) SSH Access
- Download the SSH key `tfe_dev_instance.pem` from [1Password](https://hashicorp.1password.com/vaults/2s4jfhft5ngpnudna7qx3gejue/allitems/x5sbtwr46qv5gwfqtpairt6c5u)
- SSH into the instance by
  ```
  ssh -i "tfe_dev_instance.pem" ubuntu@<PUBLIC_IP>
  ```

## Ref
- https://hashicorp.atlassian.net/wiki/spaces/IPL/pages/2617377324/Building+TFE+for+development+testing#Building-TFE-without-a-certificate-or-DNS
- https://dev.betterdoc.org/infrastructure/2020/02/04/setting-up-a-nat-gateway-on-aws-using-terraform.html
