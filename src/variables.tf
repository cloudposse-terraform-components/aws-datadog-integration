variable "region" {
  type        = string
  description = "AWS Region"
}

variable "datadog_aws_account_id" {
  type        = string
  description = "The AWS account ID Datadog's integration servers use for all integrations"
  default     = "464622532012"
}

variable "integrations" {
  type        = list(string)
  description = "List of AWS permission names to apply for different integrations (e.g. 'all', 'core')"
  default     = ["all"]
}

variable "filter_tags" {
  type = list(object({
    namespace = string
    tags      = list(string)
  }))
  description = <<-EOT
    A list of objects that filter metrics collection by namespace. Each object has a `namespace` and a
    list of `tags` in the form `key:value`. Wildcards, such as `?` (for single characters) and `*`
    (for multiple characters), can also be used in the tags.
    EOT
  default     = null
}

variable "host_tags" {
  type        = list(string)
  description = "An array of tags (in the form `key:value`) to add to all hosts and metrics reporting through this integration"
  default     = []
}

variable "excluded_regions" {
  type        = list(string)
  description = "An array of AWS regions to exclude from metrics collection"
  default     = []
}

variable "included_regions" {
  type        = list(string)
  description = "An array of AWS regions to include in metrics collection"
  default     = []
}

variable "namespace_filters_include_only" {
  type        = list(string)
  description = <<-EOT
    Include only these namespaces for metrics collection. Mutually exclusive with `namespace_filters_exclude_only`.
    Replaces the removed `account_specific_namespace_rules` input.
    EOT
  default     = null
}

variable "namespace_filters_exclude_only" {
  type        = list(string)
  description = <<-EOT
    Exclude only these namespaces from metrics collection. Mutually exclusive with `namespace_filters_include_only`.
    If neither is set, the provider defaults to excluding `["AWS/SQS", "AWS/ElasticMapReduce"]`.
    Replaces the removed `account_specific_namespace_rules` input.
    EOT
  default     = null
}

variable "context_host_and_filter_tags" {
  type        = list(string)
  description = "Automatically add host tags for these context keys (as of module v3.0.0 these are no longer added to `filter_tags`)"
  default     = ["namespace", "tenant", "stage"]
}

variable "cspm_resource_collection_enabled" {
  type        = bool
  default     = null
  description = <<-EOT
    Enable Datadog Cloud Security Posture Management scanning of your AWS account.
    See [announcement](https://www.datadoghq.com/product/cloud-security-management/cloud-security-posture-management/) for details.
    EOT
}

variable "metrics_collection_enabled" {
  type        = bool
  default     = null
  description = <<-EOT
    When enabled, a metric-by-metric crawl of the CloudWatch API pulls data and sends it
    to Datadog. New metrics are pulled every ten minutes, on average.
    EOT
}

variable "metrics_automute_enabled" {
  type        = bool
  default     = true
  description = "Enable EC2 automute for AWS metrics"
}

variable "metrics_collect_cloudwatch_alarms" {
  type        = bool
  default     = false
  description = "Enable CloudWatch alarms collection"
}

variable "metrics_collect_custom_metrics" {
  type        = bool
  default     = false
  description = "Enable custom metrics collection"
}

variable "extended_resource_collection_enabled" {
  type        = bool
  default     = true
  description = <<-EOT
    Whether Datadog collects additional attributes and configuration information about the resources
    (such as S3 Buckets, RDS snapshots, and CloudFront distributions) in your AWS account by making
    read-only API calls. Required for `cspm_resource_collection_enabled`. Replaces the removed
    `resource_collection_enabled` input.
    EOT
}
