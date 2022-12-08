data "external" "this" {
  program = ["bash", "-c", <<-EOT
    set -e

    # Search upwards for CHANGES.md
    until [ -f CHANGES.md ]; do
      cd ..
    done

    # Find the latest change
    latest=$(
      grep -E '^## [0-9]' < CHANGES.md \
      | tail -n 1 \
      | sed 's/.* //' \
      | sed 's/ .*//'
    )

    # Determine if this is a "final" release (i.e. not a pre-release version)
    # shellcheck disable=SC2001
    is_final=$(echo "$latest" | sed 's/.*-//')
    if [[ "$is_final" == "$latest" ]]; then
      is_final=true
    else
      is_final=false
    fi

    # Remove the pre-release component from the versoin number
    release="$(echo "$latest" | sed 's/-.*//')"

    # Determine the module's GIT name
    origin_module=$(git remote get-url origin 2>&1 | sed 's/.*\///' | sed 's/\.git//')
    module=$(git remote get-url ssh | sed 's/.*\///' | sed 's/\.git//')
    [ -n "$module" ] || module="$origin_module"

    # Construct the JSON output
    json=""
    json="$json{"
    json="$json  \"error\": \"error in $(pwd)\","
    json="$json  \"is_final\": \"$is_final\","
    json="$json  \"latest\": \"$latest\","
    json="$json  \"module\": \"$module\","
    json="$json  \"release\": \"$release\""
    json="$json}"

    # Output JSON
    out="$(echo -e "$json")" || {
      log="$(pwd)/$(uuidgen).log"
      echo "$out" >> "$log"
      out=""
      out="$out{"
      out="$out  \"error\": \"error in $log\""
      out="$out}"
    }
    echo "$out"
    EOT
  ]

  working_dir = var.path
}

locals {
  # See comments in "README.md".
  data = {
    is_final = try(local.result.is_final, false)
    latest   = try(local.result.latest, local.result.error)
    module   = try(local.result.module, local.result.error)
    release  = try(local.result.release, local.result.error)
  }

  # Determine of the module is the root module.
  is_root = var.path == path.root

  # The module name here is the way we want it named for the our tag. In this
  # name "terraform-aws-" and "terraform-" are converted to "tf-". For modules
  # that are not based on the "aws" provider we wil end up with names that may
  # turn out like "tf-external-foo" as our tag names.
  #
  # The root module gets a special name with "root-" as a prefix.
  module_name = replace(
    local.is_root ? "root-${local.module_short_name}" : local.module_short_name,
    "_",
    "-",
  )

  # See comment about "module_name".
  module_short_name = (
    replace(replace(local.data.module, "terraform-aws-", ""), "terraform-", "")
  )

  # The result of "s3d-flow-json"
  result = data.external.this.result

  # The tags here are the ones this module provides as output. These tags
  # include the input tags as well as a tag based on the current module.
  tags = merge(var.tags, {
    (join("-", ["tf", local.module_name])) = local.release
  })

  # We include "test" as part of our prefix if the module is a pre-release
  # version.
  release = (
    local.data.is_final ? local.data.release : "${local.data.release}-x"
  )
}
