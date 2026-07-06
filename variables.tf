variable "storage_management_policies" {
  description = <<EOT
Map of storage_management_policies, attributes below
Required:
    - storage_account_id
Optional:
    - rule (block):
        - actions (required, block):
            - base_blob (optional, block):
                - auto_tier_to_hot_from_cool_enabled (optional)
                - delete_after_days_since_creation_greater_than (optional)
                - delete_after_days_since_last_access_time_greater_than (optional)
                - delete_after_days_since_modification_greater_than (optional)
                - tier_to_archive_after_days_since_creation_greater_than (optional)
                - tier_to_archive_after_days_since_last_access_time_greater_than (optional)
                - tier_to_archive_after_days_since_last_tier_change_greater_than (optional)
                - tier_to_archive_after_days_since_modification_greater_than (optional)
                - tier_to_cold_after_days_since_creation_greater_than (optional)
                - tier_to_cold_after_days_since_last_access_time_greater_than (optional)
                - tier_to_cold_after_days_since_modification_greater_than (optional)
                - tier_to_cool_after_days_since_creation_greater_than (optional)
                - tier_to_cool_after_days_since_last_access_time_greater_than (optional)
                - tier_to_cool_after_days_since_modification_greater_than (optional)
            - snapshot (optional, block):
                - change_tier_to_archive_after_days_since_creation (optional)
                - change_tier_to_cool_after_days_since_creation (optional)
                - delete_after_days_since_creation_greater_than (optional)
                - tier_to_archive_after_days_since_last_tier_change_greater_than (optional)
                - tier_to_cold_after_days_since_creation_greater_than (optional)
            - version (optional, block):
                - change_tier_to_archive_after_days_since_creation (optional)
                - change_tier_to_cool_after_days_since_creation (optional)
                - delete_after_days_since_creation (optional)
                - tier_to_archive_after_days_since_last_tier_change_greater_than (optional)
                - tier_to_cold_after_days_since_creation_greater_than (optional)
        - enabled (required)
        - filters (required, block):
            - blob_types (required)
            - match_blob_index_tag (optional, block):
                - name (required)
                - operation (optional)
                - value (required)
            - prefix_match (optional)
        - name (required)
EOT

  type = map(object({
    storage_account_id = string
    rule = optional(list(object({
      actions = object({
        base_blob = optional(object({
          auto_tier_to_hot_from_cool_enabled                             = optional(bool)
          delete_after_days_since_creation_greater_than                  = optional(number) # Default: -1
          delete_after_days_since_last_access_time_greater_than          = optional(number) # Default: -1
          delete_after_days_since_modification_greater_than              = optional(number) # Default: -1
          tier_to_archive_after_days_since_creation_greater_than         = optional(number) # Default: -1
          tier_to_archive_after_days_since_last_access_time_greater_than = optional(number) # Default: -1
          tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number) # Default: -1
          tier_to_archive_after_days_since_modification_greater_than     = optional(number) # Default: -1
          tier_to_cold_after_days_since_creation_greater_than            = optional(number) # Default: -1
          tier_to_cold_after_days_since_last_access_time_greater_than    = optional(number) # Default: -1
          tier_to_cold_after_days_since_modification_greater_than        = optional(number) # Default: -1
          tier_to_cool_after_days_since_creation_greater_than            = optional(number) # Default: -1
          tier_to_cool_after_days_since_last_access_time_greater_than    = optional(number) # Default: -1
          tier_to_cool_after_days_since_modification_greater_than        = optional(number) # Default: -1
        }))
        snapshot = optional(object({
          change_tier_to_archive_after_days_since_creation               = optional(number) # Default: -1
          change_tier_to_cool_after_days_since_creation                  = optional(number) # Default: -1
          delete_after_days_since_creation_greater_than                  = optional(number) # Default: -1
          tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number) # Default: -1
          tier_to_cold_after_days_since_creation_greater_than            = optional(number) # Default: -1
        }))
        version = optional(object({
          change_tier_to_archive_after_days_since_creation               = optional(number) # Default: -1
          change_tier_to_cool_after_days_since_creation                  = optional(number) # Default: -1
          delete_after_days_since_creation                               = optional(number) # Default: -1
          tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number) # Default: -1
          tier_to_cold_after_days_since_creation_greater_than            = optional(number) # Default: -1
        }))
      })
      enabled = bool
      filters = object({
        blob_types = set(string)
        match_blob_index_tag = optional(object({
          name      = string
          operation = optional(string) # Default: "=="
          value     = string
        }))
        prefix_match = optional(set(string))
      })
      name = string
    })))
  }))
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || (length(v.rule) >= 1)
      )
    ])
    error_message = "Each rule list must contain at least 1 items"
  }
  # --- Unconfirmed validation candidates, derived from azurerm_storage_management_policy's provider source ---
  # Not auto-enabled: either a bespoke provider validator we can't safely translate,
  # or a path that crosses a list-typed block (needs its own for_each wrapping).
  # Review, translate into a real validation{} block above, and delete once confirmed.
  # path: storage_account_id
  #   source:    [from commonids.ValidateStorageAccountID] !ok
  # path: storage_account_id
  #   source:    [from commonids.ValidateStorageAccountID] err != nil
  # path: rule.name
  #   condition: length(value) > 0
  #   message:   must not be empty
  # path: rule.filters.blob_types[*]
  #   condition: contains(["blockBlob", "appendBlob"], value)
  #   message:   must be one of: blockBlob, appendBlob
  # path: rule.filters.match_blob_index_tag.name
  #   source:    [from validate.StorageBlobIndexTagName] len(value) == 0 || len(value) > 128
  # path: rule.filters.match_blob_index_tag.operation
  #   condition: contains(["=="], value)
  #   message:   must be one of: ==
  # path: rule.filters.match_blob_index_tag.value
  #   condition: length(value) <= 256
  #   message:   [from validate.StorageBlobIndexTagValue: invalid when len(value) > 256]
  #   source:    [from validate.StorageBlobIndexTagValue: invalid when len(value) > 256]
  # path: rule.actions.base_blob.tier_to_cool_after_days_since_modification_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.base_blob.tier_to_cool_after_days_since_last_access_time_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.base_blob.tier_to_cool_after_days_since_creation_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.base_blob.tier_to_archive_after_days_since_modification_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.base_blob.tier_to_archive_after_days_since_last_access_time_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.base_blob.tier_to_archive_after_days_since_last_tier_change_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.base_blob.tier_to_archive_after_days_since_creation_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.base_blob.tier_to_cold_after_days_since_modification_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.base_blob.tier_to_cold_after_days_since_last_access_time_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.base_blob.tier_to_cold_after_days_since_creation_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.base_blob.delete_after_days_since_modification_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.base_blob.delete_after_days_since_last_access_time_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.base_blob.delete_after_days_since_creation_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.snapshot.change_tier_to_archive_after_days_since_creation
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.snapshot.tier_to_archive_after_days_since_last_tier_change_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.snapshot.change_tier_to_cool_after_days_since_creation
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.snapshot.tier_to_cold_after_days_since_creation_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.snapshot.delete_after_days_since_creation_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.version.change_tier_to_archive_after_days_since_creation
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.version.tier_to_archive_after_days_since_last_tier_change_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.version.change_tier_to_cool_after_days_since_creation
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.version.tier_to_cold_after_days_since_creation_greater_than
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
  # path: rule.actions.version.delete_after_days_since_creation
  #   condition: value >= 0 && value <= 99999
  #   message:   must be between 0 and 99999
}

