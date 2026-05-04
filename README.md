# cl-openapi

OpenAPI 3.0 Specification parser for Common Lisp.

`cl-openapi` parses a JSON-encoded OpenAPI 3.0 document into a tree of
typed CLOS objects, giving you structured, accessor-based access to every
field defined by the specification.

## Installation

`cl-openapi` is not yet in the Quicklisp distribution.  Add it to your
project with [qlot](https://github.com/fukamachi/qlot):

```
# qlfile
github cl-openapi cl-sdk/cl-openapi :branch main
```

Then run `qlot install` and load the system:

```lisp
(ql:quickload :cl-openapi)
```

## Usage

### Parsing a document

The single public entry point is `cl-openapi:parse`.  It accepts a JSON
string, a character stream, or a binary (octet) stream and returns an
`openapi-document` instance.

```lisp
;; From a string
(defvar *doc*
  (cl-openapi:parse
   "{\"openapi\":\"3.0.0\",
     \"info\":{\"title\":\"Pet Store\",\"version\":\"1.0.0\"},
     \"paths\":{}}"))

;; From a file
(with-open-file (stream "/path/to/openapi.json")
  (defvar *doc* (cl-openapi:parse stream)))
```

### Accessing fields

Every field is exposed through a typed accessor named `<class>-<field>`:

```lisp
(cl-openapi:openapi-version *doc*)          ; => "3.0.0"

(let ((info (cl-openapi:openapi-info *doc*)))
  (cl-openapi:info-title info)              ; => "Pet Store"
  (cl-openapi:info-version info))           ; => "1.0.0"

;; Paths is a hash-table keyed by path string
(let ((item (gethash "/pets" (cl-openapi:openapi-paths *doc*))))
  (cl-openapi:operation-id
    (cl-openapi:path-item-get item)))       ; => "listPets"
```

Optional fields that are absent from the source document are left **unbound**
on their slot.  Use `slot-boundp` to test for presence before accessing them.

```lisp
(let ((info (cl-openapi:openapi-info *doc*)))
  (when (slot-boundp info 'cl-openapi::description)
    (cl-openapi:info-description info)))
```

### `$ref` handling

Wherever the specification permits a Reference Object, the decoded value is
either the concrete typed object or a `reference` instance whose single
accessor is `reference-ref` (the raw `$ref` string).

```lisp
(let ((param (aref (cl-openapi:operation-parameters op) 0)))
  (if (typep param 'cl-openapi:reference)
      (cl-openapi:reference-ref param)     ; => "#/components/parameters/Limit"
      (cl-openapi:parameter-name param)))  ; => "limit"
```

## API Reference

### Top-level

| Symbol | Description |
|--------|-------------|
| `parse input` | Parse a JSON OpenAPI document; returns an `openapi-document`. |

### Classes and accessors

#### `openapi-document`
`openapi-version` · `openapi-info` · `openapi-servers` · `openapi-paths` ·
`openapi-components` · `openapi-security` · `openapi-tags` · `openapi-external-docs`

#### `info`
`info-title` · `info-description` · `info-terms-of-service` · `info-contact` ·
`info-license` · `info-version`

#### `contact`
`contact-name` · `contact-url` · `contact-email`

#### `license`
`license-name` · `license-url`

#### `server`
`server-url` · `server-description` · `server-variables`

#### `server-variable`
`server-variable-enum` · `server-variable-default` · `server-variable-description`

#### `path-item`
`path-item-ref` · `path-item-summary` · `path-item-description` ·
`path-item-get` · `path-item-put` · `path-item-post` · `path-item-delete` ·
`path-item-options` · `path-item-head` · `path-item-patch` · `path-item-trace` ·
`path-item-servers` · `path-item-parameters`

#### `operation`
`operation-tags` · `operation-summary` · `operation-description` ·
`operation-external-docs` · `operation-id` · `operation-parameters` ·
`operation-request-body` · `operation-responses` · `operation-callbacks` ·
`operation-deprecated` · `operation-security` · `operation-servers`

#### `parameter`
`parameter-name` · `parameter-in` · `parameter-description` · `parameter-required` ·
`parameter-deprecated` · `parameter-allow-empty-value` · `parameter-style` ·
`parameter-explode` · `parameter-allow-reserved` · `parameter-schema` ·
`parameter-example` · `parameter-examples` · `parameter-content`

#### `request-body`
`request-body-description` · `request-body-content` · `request-body-required`

#### `response`
`response-description` · `response-headers` · `response-content` · `response-links`

#### `schema`
`schema-ref` · `schema-title` · `schema-description` · `schema-type` ·
`schema-format` · `schema-nullable` · `schema-default` · `schema-example` ·
`schema-deprecated` · `schema-enum` · `schema-multiple-of` · `schema-maximum` ·
`schema-exclusive-maximum` · `schema-minimum` · `schema-exclusive-minimum` ·
`schema-max-length` · `schema-min-length` · `schema-pattern` · `schema-max-items` ·
`schema-min-items` · `schema-unique-items` · `schema-items` · `schema-max-properties` ·
`schema-min-properties` · `schema-required` · `schema-properties` ·
`schema-additional-properties` · `schema-all-of` · `schema-one-of` ·
`schema-any-of` · `schema-not` · `schema-read-only` · `schema-write-only` ·
`schema-discriminator` · `schema-xml` · `schema-external-docs`

#### `components`
`components-schemas` · `components-responses` · `components-parameters` ·
`components-examples` · `components-request-bodies` · `components-headers` ·
`components-security-schemes` · `components-links` · `components-callbacks`

#### `security-scheme`
`security-scheme-type` · `security-scheme-description` · `security-scheme-name` ·
`security-scheme-in` · `security-scheme-scheme` · `security-scheme-bearer-format` ·
`security-scheme-flows` · `security-scheme-open-id-connect-url`

#### `oauth-flows`
`oauth-flows-implicit` · `oauth-flows-password` · `oauth-flows-client-credentials` ·
`oauth-flows-authorization-code`

#### `oauth-flow`
`oauth-flow-authorization-url` · `oauth-flow-token-url` · `oauth-flow-refresh-url` ·
`oauth-flow-scopes`

#### `media-type`
`media-type-schema` · `media-type-example` · `media-type-examples` · `media-type-encoding`

#### `encoding`
`encoding-content-type` · `encoding-headers` · `encoding-style` · `encoding-explode` ·
`encoding-allow-reserved`

#### `header`
`header-description` · `header-required` · `header-deprecated` ·
`header-allow-empty-value` · `header-style` · `header-explode` ·
`header-allow-reserved` · `header-schema` · `header-example` ·
`header-examples` · `header-content`

#### `example`
`example-summary` · `example-description` · `example-value` · `example-external-value`

#### `link`
`link-operation-ref` · `link-operation-id` · `link-parameters` · `link-request-body` ·
`link-description` · `link-server`

#### `tag`
`tag-name` · `tag-description` · `tag-external-docs`

#### `external-documentation`
`external-documentation-description` · `external-documentation-url`

#### `discriminator`
`discriminator-property-name` · `discriminator-mapping`

#### `xml`
`xml-name` · `xml-namespace` · `xml-prefix` · `xml-attribute` · `xml-wrapped`

#### `reference`
`reference-ref`

## License

This is free and unencumbered software released into the public domain.
See the [Unlicense](LICENSE) for details.
