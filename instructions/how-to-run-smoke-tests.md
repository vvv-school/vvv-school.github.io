# How to run smoke tests

### Usage
```sh
$ ./test.sh [path-to-smoke-test]
```
If the option `path-to-smoke-test` is not given, then the current directory
`./` is taken as input.
 
### Exit Codes

- **`0`** test passed :white_check_mark:
- **`1`** the code under test doesn't compile :hammer:
- **`2`** the test itself doesn't compile :gun:
- **`3`** test failed :x:
