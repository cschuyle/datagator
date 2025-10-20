# Dependencies
```
brew install dos2unix
```

# Moocho lists from Spotify

Export lists from Spotify:

[rawgit link](https://rawgit.com/watsonbox/exportify/master/exportify.html), valid as of March 2022, maybe will soon be deleted.

Unzip the downloaded `zip` file into the `exports` directory.

Make a local commit to git - the following command alters the files in-place.

Test that they are transformable:

```
./transform.sh
```

Undo the changes made by reverting back to the git commit you made above.


