# How to run smoke tests

### Usage
Go in the **smoke-test** subdirectory and run:
```sh
$ ./test.sh [--get-helpers]
```

### Options
- `--get-helpers` specifies to force downloading helper tools anew.

### Exit Codes
- **`0`** test passed :white_check_mark:
- **`>0`** test passed with assigned marks :ballot_box_with_check:
- **`-1`** test failed :x:
- **`-2`** code under test doesn't compile :hammer:
- **`-3`** test itself doesn't compile :gun:
- **`-4`** generic error :scream:
