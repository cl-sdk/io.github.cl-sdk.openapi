(asdf:defsystem #:io.github.cl-sdk.openapi
  :description "Open API Specification for Common Lisp."
  :license "Unlicense"
  :version "0.0.1"
  :depends-on (#:cl-json)
  :serial t
  :components ((:file "package")
               (:file "types")
               (:file "decode")))
