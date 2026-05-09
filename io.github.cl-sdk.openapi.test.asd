(asdf:defsystem #:io.github.cl-sdk.openapi.test
  :description "FiveAM test suite for io.github.cl-sdk.openapi."
  :author "cl-sdk"
  :maintainer "cl-sdk"
  :license "Unlicense"
  :homepage "https://github.com/cl-sdk/cl-openapi"
  :bug-tracker "https://github.com/cl-sdk/cl-openapi/issues"
  :source-control (:git "https://github.com/cl-sdk/cl-openapi")
  :version "0.0.1"
  :depends-on (#:fiveam
               #:io.github.cl-sdk.openapi)
  :pathname "t"
  :serial t
  :components ((:file "package")
               (:file "cl-openapi-tests")))
