# Rack::Spec
Auto-define your API server from given specs.

```ruby
# Pass a Hash as API specs
use Rack::Spec, spec: YAML.load_file("spec.yml")

# Or pass a callable object that takes an env as an argument
use Rack::Spec, spec: ->(env) { ... }
```

## Spec
You can use the [JSON Schema](http://json-schema.org/) format to define your API server.

```yaml
# Example
$schema: http://json-schema.org/draft-04/hyper-schema
title: My example API
type: object
definitions:
  recipe:
    type: object
    description: Cooking recipe
    $schema: http://json-schema.org/draft-04/hyper-schema
    description: Recipe object
    properties:
      html_url:
        $ref: "#/definitions/recipe/definitions/html_url"
      name:
        $ref: "#/definitions/recipe/definitions/name"
    definitions:
      id:
        type: integer
        description: Recipe ID
        example: 1
        readOnly: true
      name:
        type: string
        description: A name of the recipe
      html_url:
        type: string
        description: URL of recipe page
        readOnly: true
    links:
      -
        href: /recipes
        method: GET
      -
        href: /recipes/{(#/definitions/recipe/definitions/id)}
        method: PUT
        schema:
          type: object
          properties:
            name:
              $rel: "#/definitions/recipe/definitions/name"
properties:
  recipe:
    $ref: "#/definitions/recipe"
```
