(asdf:defsystem #:io.github.cl-sdk.openapi
  :description "Open API Specification for Common Lisp."
  :long-description #.(let ((readme (merge-pathnames "README.md"
                                                      (or *load-pathname*
                                                          *compile-file-pathname*))))
                        (when (probe-file readme)
                          (uiop:read-file-string readme)))
  :author "cl-sdk"
  :maintainer "cl-sdk"
  :license "Unlicense"
  :homepage "https://github.com/cl-sdk/cl-openapi"
  :bug-tracker "https://github.com/cl-sdk/cl-openapi/issues"
  :source-control (:git "https://github.com/cl-sdk/cl-openapi")
  :version "0.0.1"
  :depends-on (#:cl-json)
  :in-order-to ((test-op (load-op #:cl-openapi.test)))
  :serial t
  :components ((:file "package")
               (:file "types")
               (:file "decode")))
