# Fantasy Football SMS Updates

I wanted to build something small to learn a little about Terraform for Azure. This app creates an Azure Function (similar to AWS Lambda) and associated resources that will run every X minutes and check your ESPN fantasy football league for Recent Activity. If there is any activity in the specified interval, the function will send a configured phone number an SMS message detailing the transactions.

#### Prereq setup
Create a `function.tfvars` file which will hold your ESPN League ID, phone number, and interval. 

You can find your league Id from the URL for your fantasy league, like
`https://fantasy.espn.com/football/league/scoreboard?leagueId=5555555`

You also need two more values in the `.tfvars` file to hold some authentication values called `swid` and `espn_s2`, which can be found via the instructions here https://github.com/cwendt94/espn-api/discussions/150

After setup, your `.tfvars` should look something like
```
league_id = "5555555"
sms_number = "555-555-5555"
interval = "60"
swid = "somekindofuuid"
espn_s2 = "somelongtokenlookingthing"
```

#### Running the terraform
This section assumes you have
- Terraform installed
- A Microsoft Azure account
- The Microsoft Azure CLI installed

Login to azure
```
az login
```
Setup terraform resources
```
terraform init
terraform plan -var-file=function.tfvars -out=plan.tf
terraform apply "plan.tf"
```
Teardown terraform resources
```
terraform destroy
```