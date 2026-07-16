output "storage_management_policies_id" {
  description = "Map of id values across all storage_management_policies, keyed the same as var.storage_management_policies"
  value       = { for k, v in azurerm_storage_management_policy.storage_management_policies : k => v.id if v.id != null && length(v.id) > 0 }
}
output "storage_management_policies_rule" {
  description = "Map of rule values across all storage_management_policies, keyed the same as var.storage_management_policies"
  value       = { for k, v in azurerm_storage_management_policy.storage_management_policies : k => v.rule if v.rule != null && length(v.rule) > 0 }
}
output "storage_management_policies_storage_account_id" {
  description = "Map of storage_account_id values across all storage_management_policies, keyed the same as var.storage_management_policies"
  value       = { for k, v in azurerm_storage_management_policy.storage_management_policies : k => v.storage_account_id if v.storage_account_id != null && length(v.storage_account_id) > 0 }
}

