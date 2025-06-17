[
  #
  # Example of ignoring a specific warning:
  # ~r"lib/gatherly/some_module\.ex:.*:no_return Function.*has no local return\."s,
  #
  # You can ignore files completely:
  # ~r"lib/generated/.*"s,
  #
  # Ignore Phoenix generated files that often have type issues:
  ~r"lib/gatherly_web/components/core_components\.ex:.*:no_return"s,

  # Ignore common Phoenix/Ecto warnings that are usually false positives:
  ~r":no_return Function.*\.changeset/2 has no local return"s,
  ~r":unused_fun Function.*\.changeset/2 is unused"s,

  # Common warnings from test files:
  ~r"test/.*\.exs:.*:unused_fun"s,

  # Ignore warnings about generated types from Ecto schemas:
  ~r":invalid_contract Contract is invalid"s
]
