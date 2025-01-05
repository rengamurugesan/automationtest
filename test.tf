
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




# Key Lifecycle Meta-Arguments

# lifecycle { prevent_destroy = true }
# lifecycle { create_before_destroy = true }
# lifecycle { ignore_changes = [tags, network_interface_ids] }
# lifecycle { replace_triggered_by = [ azurerm_storage_account.example, azurerm_virtual_network.example ] }


resource "azurerm_maps_account" "maps_account" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  sku_name                     = var.sku_name
  local_authentication_enabled = false
  dynamic "location" {
    for_each = try(var.location, null) != null ? [1] : []
    content {
      location = var.location
    }
  }
  dynamic "cors" {
    for_each = try(var.cors, null) != null ? [var.cors] : []
    content {
      allowed_origins = [var.allowed_origins]
    }
  }
  dynamic "data_store" {
    for_each = try(var.data_store, null) != null ? [var.data_store] : []
    content {
      storage_account_id = var.storage_account_id
      unique_name        = var.unique_name
    }
  }
  dynamic "identity" {
    for_each = var.identity_ids
    content {
      type         = "UserAssigned"
      identity_ids = [var.identity_ids]
    }
  }
  dynamic "timeouts" {
    for_each = try(var.timeouts, null) != null ? var.timeouts : []
    content {
      create = lookup(var.timeouts, "create", "30m")
      update = lookup(var.timeouts, "update", "30m")
      read   = lookup(var.timeouts, "read", "5m")
      delete = lookup(var.timeouts, "delete", "30m")
    }
  }
  tags = {
    environment = "Test"
  }

}


output "id" {
  value       = azurerm_maps_account.maps_account.id
  description = "The ID of the Azure Maps Account."
}
output "identity" {
  description = <<EOT
                "An identity block exports the following:
                   principal_id - The Principal ID associated with this Managed Service Identity.
                  tenant_id - The Tenant ID associated with this Managed Service Identity."
                  EOT
  value       = azurerm_maps_account.maps_account.identity
}

output "x_ms_client_id" {
  value       = azurerm_maps_account.maps_account.x_ms_client_id
  description = "A unique identifier for the Maps Account."

}

variable "name" {
  description = "(Required) The name of the Azure Maps Account. Changing this forces a new resource to be created."
  type        = string

}

variable "resource_group_name" {
  description = "(Required) The name of the Resource Group in which the Azure Maps Account should exist. Changing this forces a new resource to be created."
  type        = string

}
variable "sku_name" {
  description = "(Required) The SKU of the Azure Maps Account. Possible values are S0, S1 and G2. Changing this forces a new resource to be created."
  type        = string
  default     = "G2"

}
variable "location" {
  description = "(Optional) The Location in which the Azure Maps Account should be provisioned. Changing this forces a new resource to be created. Defaults to global."
  type        = string
  default     = "global"


}
variable "cors" {
  description = <<EOT
    (Optional) - A cors block as defined below
    allowed_origins - (Required) A list of origins that should be allowed to make cross-origin calls.
    EOT
  type        = any
  default     = []
}
variable "data_store" {
  description = <<EOT
  A data_store block supports the following
  storage_account_id - (Required) The ID of the Storage Account that should be linked to this Azure Maps Account.
  unique_name - (Required) The name given to the linked Storage Account.
  EOT
  type        = any
  default     = []
}
variable "identity_ids" {
  description = "list of User Assigned Managed Identity IDs to be assigned to this Azure Maps Account."
  type        = list(string)
}

variable "timeouts" {
  description = <<EOT
    create - (Defaults to 30 minutes) Used when creating the Maps Account.
update - (Defaults to 30 minutes) Used when updating the Maps Account.
read - (Defaults to 5 minutes) Used when retrieving the Maps Account.
delete - (Defaults to 30 minutes) Used when deleting the Maps Account.
EOT
  type        = any
  default     = []

}

variable "tags" {
  description = "A mapping of tags to assign to the Azure Maps Account."
  type        = any

}
