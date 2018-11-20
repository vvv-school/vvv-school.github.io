# How to run smoke tests

### Usage
Go in the **smoke-test** subdirectory and run:
```sh
$ ./test.sh [--get-helpers]
```

### Options
- `--get-helpers` specifies to download helper tools anew.

### Exit Codes
- **`0`** test passed :heavy_check_mark:
- **`>=1 && <=100`** test passed with assigned marks :ballot_box_with_check:
- **`-1`**(=255) test failed :x:
- **`-2`**(=254) code under test doesn't compile :hammer:
- **`-3`**(=253) test itself doesn't compile :gun:
- **`-4`**(=252) generic error :scream:
