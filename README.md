# Datagator

Datagator is a lightweight flexible framework to ingest, store, and analyze Data about Data 

## Ingestion
A collection of scripts to extract, transform, and publish data from a number of websites.

## Usage

### Setup
TODO:
Configure by using `datagator-config-template`,  copy it to `~/.datagator` and fill-in the blanks. Alternatively, set env vars (see `datagator-config-template` file for details).

### Create local data

#### Netflix Queue

[Parse the DVD Queue page](./netflix), which you might find useful prior to Netflix DVD ceasing operations on Sept. 28, 2023 

#### Little Prince Collection

2. The Little Prince Collection (https://www.petit-prince-collection.com)

```console
dg get PP-7146
```
Scrapes Little Prince Collection data from https://www.petit-prince-collection.com/lang/show_livre.php?lang=en&id=7146

Output:
- `$DGOUT/PP/$PPID/items.json` JSON array of Datagator-format records including metadata
- `$DGOUT/PP/$PPID/raw-covers` Downloaded resources (images)

### Publish local data to an environment

`dg build` Do *some* validation on local data and build the publishable artifacts.

`dg publish` Upload (reconcile) all local data to the cloud deployment.
