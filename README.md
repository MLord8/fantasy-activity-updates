# Fantasy Football SMS Updates

I wanted to build something small to learn a little about Terraform for Azure. This app creates an Azure Function (similar to AWS Lambda) and associated resources that will run every X minutes and check your ESPN fantasy football league for Recent Activity. If there is any activity in the specified interval, the function will send a configured email address a  message detailing the transactions.

#### Prereq setup
Create a `function.tfvars` file which will hold your ESPN League ID, email, and interval. 

You can find your league Id from the URL for your fantasy league, like
`https://fantasy.espn.com/football/league/scoreboard?leagueId=5555555`

You also need two more values in the `.tfvars` file to hold some authentication values called `swid` and `espn_s2`, which can be found via the instructions here https://github.com/cwendt94/espn-api/discussions/150

After setup, your `.tfvars` should look something like
```
league_id = "5555555"
email = "yourname@email.com"
interval = "60"
swid = "somekindofuuid"
espn_s2 = "somelongtokenlookingthing"
```

#### Running the terraform
This section assumes you have
- Terraform installed (https://learn.hashicorp.com/tutorials/terraform/install-cli)
- A Microsoft Azure account
- The Microsoft Azure CLI installed (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Microsoft Azure Function Apps CLI installed (https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=v4%2Cmacos%2Ccsharp%2Cportal%2Cbash)

Login to azure
```
az login
```
Setup terraform resources\
:boom: Adding these resources to your Azure account will incur charges.
```
cd terraform
terraform init
terraform plan -var-file=function.tfvars -out=plan.tf
terraform apply "plan.tf"
```
Teardown terraform resources
```
terraform destroy
```

#### Add an email domain to the communications resource
Unfortunately there's not a way to connect an email domain to an Azure communications service terraform resource. See these instructions under "Provision Managed Domain" for adding an email domain to the created ff-email-messages communications service. https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/email/add-azure-managed-domains\

Add the domain to `function.tfvars` to a variable called `azure_email_domain`.\
Remote the old terraform plan
```
cd terraform
rm plan.tf
```
Change the terraform resources using the same steps as above.

#### Deploy the function code to Azure
```
func azure functionapp publish ff-email-updates
```