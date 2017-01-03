# How to run smoke tests

### Usage
Go in the **smoke-test** subdirectory and run:
```sh
$ ./test.sh
```

### Exit Codes

- **`0`** test passed :white_check_mark:
- **`1`** code under test doesn't compile :hammer:
- **`2`** test itself doesn't compile :gun:
- **`3`** test failed :x:
- **`4`** generic error :scream:
