# Coveralls configuration for Gatherly
[
  # Coverage minimum threshold
  minimum_coverage: 80,

  # Skip files/paths from coverage
  skip_files: [
    "lib/gatherly/application.ex",
    "lib/gatherly/release.ex",
    "lib/gatherly_web.ex",
    "lib/gatherly_web/endpoint.ex",
    "lib/gatherly_web/router.ex",
    "lib/gatherly_web/telemetry.ex",
    "test/support",
    "priv"
  ],

  # Terminal output options
  terminal_options: [
    file_column_width: 40
  ],

  # HTML report options
  html_options: [
    extra_css: """
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
    .coverage-summary { margin: 20px 0; }
    """,
    custom_title: "Gatherly Test Coverage Report"
  ],

  # Treat these as warnings rather than failures
  treat_no_relevant_lines_as_covered: true,

  # GitHub integration
  service_name: "github",

  # XML output for CI/CD integration
  xml_options: [
    output_dir: "cover/"
  ]
]