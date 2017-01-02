# How to run smoke tests

### Usage
Go in the **smoke-test** subdirectory and run:
```sh
$ ./test.sh
```

### Exit Codes

- **`0`** test passed :white_check_mark:
- **`1`** the code under test doesn't compile :hammer:
- **`2`** the test itself doesn't compile :gun:
- **`3`** test failed :x:
