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
          delete_after_days_since_creation_greater_than                  = optional(number)
          delete_after_days_since_last_access_time_greater_than          = optional(number)
          delete_after_days_since_modification_greater_than              = optional(number)
          tier_to_archive_after_days_since_creation_greater_than         = optional(number)
          tier_to_archive_after_days_since_last_access_time_greater_than = optional(number)
          tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)
          tier_to_archive_after_days_since_modification_greater_than     = optional(number)
          tier_to_cold_after_days_since_creation_greater_than            = optional(number)
          tier_to_cold_after_days_since_last_access_time_greater_than    = optional(number)
          tier_to_cold_after_days_since_modification_greater_than        = optional(number)
          tier_to_cool_after_days_since_creation_greater_than            = optional(number)
          tier_to_cool_after_days_since_last_access_time_greater_than    = optional(number)
          tier_to_cool_after_days_since_modification_greater_than        = optional(number)
        }))
        snapshot = optional(object({
          change_tier_to_archive_after_days_since_creation               = optional(number)
          change_tier_to_cool_after_days_since_creation                  = optional(number)
          delete_after_days_since_creation_greater_than                  = optional(number)
          tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)
          tier_to_cold_after_days_since_creation_greater_than            = optional(number)
        }))
        version = optional(object({
          change_tier_to_archive_after_days_since_creation               = optional(number)
          change_tier_to_cool_after_days_since_creation                  = optional(number)
          delete_after_days_since_creation                               = optional(number)
          tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)
          tier_to_cold_after_days_since_creation_greater_than            = optional(number)
        }))
      })
      enabled = bool
      filters = object({
        blob_types = set(string)
        match_blob_index_tag = optional(list(object({
          name      = string
          operation = optional(string)
          value     = string
        })))
        prefix_match = optional(set(string))
      })
      name = string
    })))
  }))
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (length(item.name) > 0)])
      )
    ])
    error_message = "must not be empty"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (alltrue([for x in item.filters.blob_types : contains(["blockBlob", "appendBlob"], x)]))])
      )
    ])
    error_message = "must be one of: blockBlob, appendBlob"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.filters.match_blob_index_tag == null || alltrue([for item in item.filters.match_blob_index_tag : (item.operation == null || (contains(["=="], item.operation)))]))])
      )
    ])
    error_message = "must be one of: =="
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.filters.match_blob_index_tag == null || alltrue([for item in item.filters.match_blob_index_tag : (length(item.value) <= 256)]))])
      )
    ])
    error_message = "[from validate.StorageBlobIndexTagValue: invalid when len(value) > 256]"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.tier_to_cool_after_days_since_modification_greater_than == null || (item.actions.base_blob.tier_to_cool_after_days_since_modification_greater_than >= 0 && item.actions.base_blob.tier_to_cool_after_days_since_modification_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.tier_to_cool_after_days_since_last_access_time_greater_than == null || (item.actions.base_blob.tier_to_cool_after_days_since_last_access_time_greater_than >= 0 && item.actions.base_blob.tier_to_cool_after_days_since_last_access_time_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.tier_to_cool_after_days_since_creation_greater_than == null || (item.actions.base_blob.tier_to_cool_after_days_since_creation_greater_than >= 0 && item.actions.base_blob.tier_to_cool_after_days_since_creation_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.tier_to_archive_after_days_since_modification_greater_than == null || (item.actions.base_blob.tier_to_archive_after_days_since_modification_greater_than >= 0 && item.actions.base_blob.tier_to_archive_after_days_since_modification_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.tier_to_archive_after_days_since_last_access_time_greater_than == null || (item.actions.base_blob.tier_to_archive_after_days_since_last_access_time_greater_than >= 0 && item.actions.base_blob.tier_to_archive_after_days_since_last_access_time_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.tier_to_archive_after_days_since_last_tier_change_greater_than == null || (item.actions.base_blob.tier_to_archive_after_days_since_last_tier_change_greater_than >= 0 && item.actions.base_blob.tier_to_archive_after_days_since_last_tier_change_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.tier_to_archive_after_days_since_creation_greater_than == null || (item.actions.base_blob.tier_to_archive_after_days_since_creation_greater_than >= 0 && item.actions.base_blob.tier_to_archive_after_days_since_creation_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.tier_to_cold_after_days_since_modification_greater_than == null || (item.actions.base_blob.tier_to_cold_after_days_since_modification_greater_than >= 0 && item.actions.base_blob.tier_to_cold_after_days_since_modification_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.tier_to_cold_after_days_since_last_access_time_greater_than == null || (item.actions.base_blob.tier_to_cold_after_days_since_last_access_time_greater_than >= 0 && item.actions.base_blob.tier_to_cold_after_days_since_last_access_time_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.tier_to_cold_after_days_since_creation_greater_than == null || (item.actions.base_blob.tier_to_cold_after_days_since_creation_greater_than >= 0 && item.actions.base_blob.tier_to_cold_after_days_since_creation_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.delete_after_days_since_modification_greater_than == null || (item.actions.base_blob.delete_after_days_since_modification_greater_than >= 0 && item.actions.base_blob.delete_after_days_since_modification_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.delete_after_days_since_last_access_time_greater_than == null || (item.actions.base_blob.delete_after_days_since_last_access_time_greater_than >= 0 && item.actions.base_blob.delete_after_days_since_last_access_time_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.base_blob == null || (item.actions.base_blob.delete_after_days_since_creation_greater_than == null || (item.actions.base_blob.delete_after_days_since_creation_greater_than >= 0 && item.actions.base_blob.delete_after_days_since_creation_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.snapshot == null || (item.actions.snapshot.change_tier_to_archive_after_days_since_creation == null || (item.actions.snapshot.change_tier_to_archive_after_days_since_creation >= 0 && item.actions.snapshot.change_tier_to_archive_after_days_since_creation <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.snapshot == null || (item.actions.snapshot.tier_to_archive_after_days_since_last_tier_change_greater_than == null || (item.actions.snapshot.tier_to_archive_after_days_since_last_tier_change_greater_than >= 0 && item.actions.snapshot.tier_to_archive_after_days_since_last_tier_change_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.snapshot == null || (item.actions.snapshot.change_tier_to_cool_after_days_since_creation == null || (item.actions.snapshot.change_tier_to_cool_after_days_since_creation >= 0 && item.actions.snapshot.change_tier_to_cool_after_days_since_creation <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.snapshot == null || (item.actions.snapshot.tier_to_cold_after_days_since_creation_greater_than == null || (item.actions.snapshot.tier_to_cold_after_days_since_creation_greater_than >= 0 && item.actions.snapshot.tier_to_cold_after_days_since_creation_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.snapshot == null || (item.actions.snapshot.delete_after_days_since_creation_greater_than == null || (item.actions.snapshot.delete_after_days_since_creation_greater_than >= 0 && item.actions.snapshot.delete_after_days_since_creation_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.version == null || (item.actions.version.change_tier_to_archive_after_days_since_creation == null || (item.actions.version.change_tier_to_archive_after_days_since_creation >= 0 && item.actions.version.change_tier_to_archive_after_days_since_creation <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.version == null || (item.actions.version.tier_to_archive_after_days_since_last_tier_change_greater_than == null || (item.actions.version.tier_to_archive_after_days_since_last_tier_change_greater_than >= 0 && item.actions.version.tier_to_archive_after_days_since_last_tier_change_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.version == null || (item.actions.version.change_tier_to_cool_after_days_since_creation == null || (item.actions.version.change_tier_to_cool_after_days_since_creation >= 0 && item.actions.version.change_tier_to_cool_after_days_since_creation <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.version == null || (item.actions.version.tier_to_cold_after_days_since_creation_greater_than == null || (item.actions.version.tier_to_cold_after_days_since_creation_greater_than >= 0 && item.actions.version.tier_to_cold_after_days_since_creation_greater_than <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  validation {
    condition = alltrue([
      for k, v in var.storage_management_policies : (
        v.rule == null || alltrue([for item in v.rule : (item.actions.version == null || (item.actions.version.delete_after_days_since_creation == null || (item.actions.version.delete_after_days_since_creation >= 0 && item.actions.version.delete_after_days_since_creation <= 99999)))])
      )
    ])
    error_message = "must be between 0 and 99999"
  }
  # Note: 3 additional provider-side validators are enforced at apply time but not mirrored as validation{} blocks here (bespoke or non-mechanically-translatable).
}

