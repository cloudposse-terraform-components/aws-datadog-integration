locals {
  use_include_regions      = length(var.included_regions) > 0
  all_regions              = data.aws_regions.all.names
  excluded_list_by_include = setsubtract(local.use_include_regions ? local.all_regions : [], var.included_regions)
}

data "aws_regions" "all" {
  all_regions = true
}

module "datadog_integration" {
  source  = "cloudposse/datadog-integration/aws"
  version = "3.0.0"

  enabled = module.this.enabled && length(var.integrations) > 0

  datadog_aws_account_id = var.datadog_aws_account_id
  integrations           = var.integrations
  filter_tags            = var.filter_tags
  host_tags              = local.host_tags
  excluded_regions       = concat(var.excluded_regions, tolist(local.excluded_list_by_include))

  namespace_filters_include_only = var.namespace_filters_include_only
  namespace_filters_exclude_only = var.namespace_filters_exclude_only

  cspm_resource_collection_enabled     = var.cspm_resource_collection_enabled
  extended_resource_collection_enabled = var.extended_resource_collection_enabled

  metrics_collection_enabled        = var.metrics_collection_enabled
  metrics_automute_enabled          = var.metrics_automute_enabled
  metrics_collect_cloudwatch_alarms = var.metrics_collect_cloudwatch_alarms
  metrics_collect_custom_metrics    = var.metrics_collect_custom_metrics

  context = module.this.context
}

locals {
  enabled = module.this.enabled

  # Get the context tags and skip tags that we don't want applied to every resource.
  # i.e. we don't want name since each metric would be called something other than this component's name.
  # i.e. we don't want environment since each metric would come from gbl or a region and this component is deployed in gbl.
  # These context tags are added to `host_tags` only. As of module v3.0.0, `filter_tags` is a list of
  # per-namespace objects rather than a flat list of `key:value` strings, so context tags are no longer
  # injected into it.
  context_tags = [
    for k, v in module.this.tags : "${lower(k)}:${v}" if contains(var.context_host_and_filter_tags, lower(k))
  ]
  host_tags = distinct(concat(var.host_tags, local.context_tags))
}

module "store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.13.0"

  parameter_write = [
    {
      name        = "/datadog/datadog_external_id"
      value       = join("", module.datadog_integration[*].datadog_external_id)
      type        = "String"
      overwrite   = "true"
      description = "External identifier for our dd integration"
    },
    {
      name        = "/datadog/aws_role_name"
      value       = join("", module.datadog_integration[*].aws_role_name)
      type        = "String"
      overwrite   = "true"
      description = "Name of the AWS IAM role used by our dd integration"
    }
  ]

  context = module.this.context
}
