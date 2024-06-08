defmodule GatherlyWeb.Layouts.SwiftUI do
  use GatherlyNative, [:layout, format: :swiftui]

  embed_templates "layouts_swiftui/*"
end
