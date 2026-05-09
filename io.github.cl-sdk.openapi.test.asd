(asdf:defsystem #:io.github.cl-sdk.openapi.test
  :description "FiveAM test suite for io.github.cl-sdk.openapi."
  :license "Unlicense"
  :version "0.0.1"
  :depends-on (#:fiveam
               #:io.github.cl-sdk.openapi)
  :pathname "t"
  :serial t
  :components ((:file "package")
               (:file "cl-openapi-tests")))
