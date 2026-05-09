(defpackage #:io.github.cl-sdk.openapi
  (:use #:cl)
  (:export
   ;; Top-level entry point
   #:parse

   ;; Document
   #:openapi-document
   #:openapi-version
   #:openapi-info
   #:openapi-servers
   #:openapi-paths
   #:openapi-components
   #:openapi-security
   #:openapi-tags
   #:openapi-external-docs

   ;; Info
   #:info
   #:info-title
   #:info-description
   #:info-terms-of-service
   #:info-contact
   #:info-license
   #:info-version

   ;; Contact
   #:contact
   #:contact-name
   #:contact-url
   #:contact-email

   ;; License
   #:license
   #:license-name
   #:license-url

   ;; Server
   #:server
   #:server-url
   #:server-description
   #:server-variables

   ;; Server variable
   #:server-variable
   #:server-variable-enum
   #:server-variable-default
   #:server-variable-description

   ;; Components
   #:components
   #:components-schemas
   #:components-responses
   #:components-parameters
   #:components-examples
   #:components-request-bodies
   #:components-headers
   #:components-security-schemes
   #:components-links
   #:components-callbacks

   ;; Path item
   #:path-item
   #:path-item-ref
   #:path-item-summary
   #:path-item-description
   #:path-item-get
   #:path-item-put
   #:path-item-post
   #:path-item-delete
   #:path-item-options
   #:path-item-head
   #:path-item-patch
   #:path-item-trace
   #:path-item-servers
   #:path-item-parameters

   ;; Operation
   #:operation
   #:operation-tags
   #:operation-summary
   #:operation-description
   #:operation-external-docs
   #:operation-id
   #:operation-parameters
   #:operation-request-body
   #:operation-responses
   #:operation-callbacks
   #:operation-deprecated
   #:operation-security
   #:operation-servers

   ;; External documentation
   #:external-documentation
   #:external-documentation-description
   #:external-documentation-url

   ;; Parameter
   #:parameter
   #:parameter-name
   #:parameter-in
   #:parameter-description
   #:parameter-required
   #:parameter-deprecated
   #:parameter-allow-empty-value
   #:parameter-style
   #:parameter-explode
   #:parameter-allow-reserved
   #:parameter-schema
   #:parameter-example
   #:parameter-examples
   #:parameter-content

   ;; Request body
   #:request-body
   #:request-body-description
   #:request-body-content
   #:request-body-required

   ;; Media type
   #:media-type
   #:media-type-schema
   #:media-type-example
   #:media-type-examples
   #:media-type-encoding

   ;; Encoding
   #:encoding
   #:encoding-content-type
   #:encoding-headers
   #:encoding-style
   #:encoding-explode
   #:encoding-allow-reserved

   ;; Response
   #:response
   #:response-description
   #:response-headers
   #:response-content
   #:response-links

   ;; Example
   #:example
   #:example-summary
   #:example-description
   #:example-value
   #:example-external-value

   ;; Link
   #:link
   #:link-operation-ref
   #:link-operation-id
   #:link-parameters
   #:link-request-body
   #:link-description
   #:link-server

   ;; Header
   #:header
   #:header-description
   #:header-required
   #:header-deprecated
   #:header-allow-empty-value
   #:header-style
   #:header-explode
   #:header-allow-reserved
   #:header-schema
   #:header-example
   #:header-examples
   #:header-content

   ;; Tag
   #:tag
   #:tag-name
   #:tag-description
   #:tag-external-docs

   ;; Schema
   #:schema
   #:schema-ref
   #:schema-title
   #:schema-multiple-of
   #:schema-maximum
   #:schema-exclusive-maximum
   #:schema-minimum
   #:schema-exclusive-minimum
   #:schema-max-length
   #:schema-min-length
   #:schema-pattern
   #:schema-max-items
   #:schema-min-items
   #:schema-unique-items
   #:schema-max-properties
   #:schema-min-properties
   #:schema-required
   #:schema-enum
   #:schema-type
   #:schema-all-of
   #:schema-one-of
   #:schema-any-of
   #:schema-not
   #:schema-items
   #:schema-properties
   #:schema-additional-properties
   #:schema-description
   #:schema-format
   #:schema-default
   #:schema-nullable
   #:schema-discriminator
   #:schema-read-only
   #:schema-write-only
   #:schema-xml
   #:schema-external-docs
   #:schema-example
   #:schema-deprecated

   ;; Discriminator
   #:discriminator
   #:discriminator-property-name
   #:discriminator-mapping

   ;; XML
   #:xml
   #:xml-name
   #:xml-namespace
   #:xml-prefix
   #:xml-attribute
   #:xml-wrapped

   ;; Security scheme
   #:security-scheme
   #:security-scheme-type
   #:security-scheme-description
   #:security-scheme-name
   #:security-scheme-in
   #:security-scheme-scheme
   #:security-scheme-bearer-format
   #:security-scheme-flows
   #:security-scheme-open-id-connect-url

   ;; OAuth flows
   #:oauth-flows
   #:oauth-flows-implicit
   #:oauth-flows-password
   #:oauth-flows-client-credentials
   #:oauth-flows-authorization-code

   ;; OAuth flow
   #:oauth-flow
   #:oauth-flow-authorization-url
   #:oauth-flow-token-url
   #:oauth-flow-refresh-url
   #:oauth-flow-scopes

   ;; Reference ($ref)
   #:reference
   #:reference-ref))

(in-package :io.github.cl-sdk.openapi)
