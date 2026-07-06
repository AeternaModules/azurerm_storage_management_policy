output "storage_management_policies" {
  description = "All storage_management_policy resources"
  value       = azurerm_storage_management_policy.storage_management_policies
}
output "storage_management_policies_rule" {
  description = "List of rule values across all storage_management_policies"
  value       = [for k, v in azurerm_storage_management_policy.storage_management_policies : v.rule]
}
output "storage_management_policies_storage_account_id" {
  description = "List of storage_account_id values across all storage_management_policies"
  value       = [for k, v in azurerm_storage_management_policy.storage_management_policies : v.storage_account_id]
}

