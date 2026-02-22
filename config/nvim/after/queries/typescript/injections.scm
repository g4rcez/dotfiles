; extends
(call_expression
  function: (identifier) @injection.language
  (#eq? @injection.language "sql")
  arguments: (template_string) @injection.content)

; extends
(call_expression
  function: (identifier) @injection.language
  (#eq? @injection.language "css")
  arguments: (template_string) @injection.content)
