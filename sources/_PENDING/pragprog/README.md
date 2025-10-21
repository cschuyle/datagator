# Pragmatic Programmers

Go to <progprog.com>, log in

Click on *My Orders*

Copy-paste the table into `pragprog.txt`, edit if need be. The format should be simple and self-explanatory.

The pipeline will do all the work. To test it locally:

```
./transform.sh
ls -l ../../tmp/private/pragprog.json # Make sure the timestamp is now
less ../../tmp/private/pragprog.json
```

