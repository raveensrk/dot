# Notes

## How to redirect all the text to /dev/null?

```bash
cat file.txt 1> /dev/null 2>&1
```
Read this from right to left
Std error 2 is redirected to std out 1, std out 1 is redirected to /dev/null
