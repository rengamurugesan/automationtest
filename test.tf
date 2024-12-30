
resource "azurerm_automation_account" "automation" {
  name                = "test12"
  location            = "Southeast Asia"
  resource_group_name = "rg-vms"
  sku_name            = "Free"
  identity {
    type         = "UserAssigned"
    identity_ids = ["/subscriptions/<>/resourceGroups/rg-terraform-webpubsub/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-webpubsub", ]

  }
  encryption {
    key_vault_key_id = "https://kv-webpubsub.vault.azure.net/keys/automation-4096/c2a5646bfef8465b8359a5652e1c600c/" #"https://kv-webpubsub.vault.azure.net/keys/automation-4096/c2a5646bfef8465b8359a5652e1c600c/"

    user_assigned_identity_id = "/subscriptions/<>/resourceGroups/rg-terraform-webpubsub/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-webpubsub"


  }
}


resource "azurerm_automation_runbook" "automation_runbook" {
  name                    = "customcontent"
  location                = "Southeast Asia"
  resource_group_name     = "rg-vms"
  automation_account_name = "test12"
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is an example runbook"
  runbook_type            = "PowerShellWorkflow"
  content                 = file("./draftcontent.ps1")

  depends_on = [azurerm_automation_account.automation]
}

resource "azurerm_automation_runbook" "automation_runbook2" {
  name                    = "Get-AzureVMTutorial"
  location                = "Southeast Asia"
  resource_group_name     = "rg-vms"
  automation_account_name = "test12"
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is an example runbook"
  runbook_type            = "PowerShellWorkflow"

  publish_content_link {
    uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
  }
  depends_on = [azurerm_automation_account.automation]
}


data "local_file" "example" {
  filename = "draftcontent.ps1"
}

resource "azurerm_automation_runbook" "automation_runbook1" {
  name                    = "draftrunbook"
  location                = "Southeast Asia"
  resource_group_name     = "rg-vms"
  automation_account_name = "test12"
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is an example runbook"
  runbook_type            = "PowerShell"

  #content                 = filebase64("./draftcontent.ps1")
  #content = data.local_file.example.content

  draft {
    edit_mode_enabled = "true"
    content_link {
      uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
    }
    parameters {
      key           = "tets"
      type          = "string"
      mandatory     = true
      position      = 0
      default_value = "test1"
    }

  }



  #content = file("./draftcontent.ps1")

  # publish_content_link {
  #   uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
  # }
  depends_on = [azurerm_automation_account.automation]
}


resource "azurerm_automation_source_control" "source_control" {
  name                    = "test"
  automation_account_id   = azurerm_automation_account.automation.id
  folder_path             = "/"
  publish_runbook_enabled = false
  automatic_sync          = false

  security {
    token      = ""
    token_type = "PersonalAccessToken"
  }
  repository_url      = ""
  source_control_type = "GitHub"
  branch              = "master"
}

resource "azurerm_automation_schedule" "monthly_schedule" {
  name                    = "tf-month-schedule-001"
  automation_account_name = "test12"
  resource_group_name     = "rg-vms"
  frequency               = "Month"
  interval                = 1
  timezone                = "UTC"
  start_time              = "2028-04-15T18:00:15+02:00"
  description             = "This is an example schedule"
  monthly_occurrence {
    day        = "Monday"
    occurrence = 4
  }
}
resource "azurerm_automation_schedule" "monthly_schedule1" {
  name                    = "tf-month-days-schedule-002"
  automation_account_name = "test12"
  resource_group_name     = "rg-vms"
  frequency               = "Month"
  interval                = 1
  timezone                = "UTC"
  start_time              = "2028-04-15T18:00:15+02:00"
  description             = "This is an example schedule"
  month_days              = [1, 3, 5] 
}

resource "azurerm_automation_schedule" "weekly_schedule" {
  name                    = "tf-week-schedule"
  automation_account_name = "test12"
  resource_group_name     = "rg-vms"
  frequency               = "Week"
  interval                = 1
  timezone                = "UTC"
  start_time              = "2028-04-15T18:00:15+02:00"
  description             = "This is an example schedule"
  week_days               = ["Friday"]
}


