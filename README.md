# `per1234/artistic-style-action`

A [GitHub Actions](https://github.com/features/actions) action for checking code formatting with [Artistic Style](http://astyle.sourceforge.net/).

Please see [action.yml](./action.yml) for the documentation of the action's inputs.

## Example usage

```yaml
on: [pull_request, push]
jobs:
  check-formatting:
    steps:
      - uses: actions/checkout@v2
      - uses: per1234/artistic-style-action@main
        with:
          name-patterns: |
            - '*.cpp'
            - '*.h'
```

#### Contributing
Pull requests or issue reports are welcome! Please see the [contribution rules](.github/CONTRIBUTING.md) for instructions.
