# Tintenfass publishers eBooks

## Add new titles as Tintenfass releases them

Get the entire list:
```
dg tintenfass
```

Copy what does not exist yet into `tintenfass-little-prince.json`.

Edit the text, especially paying attention to the 3 `title` fields (collapse them into one),
and the `language` field.

For good measure, make sure the transform.sh script (which is called by the pipeline) works:
```
./transform.sh
```

## Mark items as owned

Add `"owned": "true"` to the items that you already have.

Manually merge the items into the `little-prince.json` file in the `little-prince` Trove.

## What do I buy next?

To find the books that I don't yet own (according to the json file):
```
./buy-next.sh
```

## To just get a summary of the exported list
```
./summary.sh
```

If you want to run it on the export from `dg tintenfass` diretly, add some boilerplate to make the json file well-formed:
```
{
  "id": "tintenfass-little-prince",
  "name": "Tintenfaß Little Prince translations",
  "shortName": "Tintenfaß Little Prince",
  "items": [
    
    ...

]
}

```
