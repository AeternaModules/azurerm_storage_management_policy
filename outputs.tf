output "storage_management_policies_id" {
  description = "Map of id values across all storage_management_policies, keyed the same as var.storage_management_policies"
  value       = { for k, v in azurerm_storage_management_policy.storage_management_policies : k => v.id }
}
output "storage_management_policies_rule" {
  description = "Map of rule values across all storage_management_policies, keyed the same as var.storage_management_policies"
  value       = { for k, v in azurerm_storage_management_policy.storage_management_policies : k => v.rule }
}
output "storage_management_policies_storage_account_id" {
  description = "Map of storage_account_id values across all storage_management_policies, keyed the same as var.storage_management_policies"
  value       = { for k, v in azurerm_storage_management_policy.storage_management_policies : k => v.storage_account_id }
}

