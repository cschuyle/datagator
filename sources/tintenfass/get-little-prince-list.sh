#!/usr/bin/env bash

#{
#  "Nr": "67",
#  "NrZusatz": "",
#  "Sortierung": "0067.",
#  "Erscheinungsdatum": "05.06.2009",
#  "VLB_ISBN13": "978-3-937467-63-4",
#  "ISBN13": "978-3-937467-63-4",
#  "Originaler_Autor": "de Saint-Exupéry, Antoine",
#  "Übersetzer_Autor": "Froschauer, Regine",
#  "Intern_Titel": "Dher luzzilfuristo ",
#  "Titel": "Dher luzzilfuristo",
#  "Untertitel": "Der kleine Prinz - Althochdeutsch",
#  "Beschreibung": "Übersetzung des Kleinen Prinzen ins frühalemannische Althochdeutsch, Ende 8. / Anfang 9. Jh. Ein cleverer Philologenspaß!",
#  "Beschreibung_de": "Übersetzung des Kleinen Prinzen ins frühalemannische Althochdeutsch, Ende 8. / Anfang 9. Jh. Ein cleverer Philologenspaß!",
#  "Beschreibung_en": "Translation of “The Little Prince“ into Early Alemannic Old High German, late 8th / early 9th c. A clever delight for every philologist!",
#  "Thema": "LPP",
#  "Sprache": "Althochdeutsch",
#  "Sprachgruppe": null,
#  "Jahr": 2009,
#  "Land": "D",
#  "Kontinent": "Europa",
#  "lieferbar": true,
#  "VK": 22,
#  "Produkthöhe": 22,
#  "Produktbreite": 16,
#  "Produktgewicht": 250,
#  "Seiten": "ca 96",
#  "Abbildungen": ""
#}

curl https://editiontintenfass.de/catalog.json | jq '
[.[] | select(.Originaler_Autor | test("Antoine")) |
  .Description = (.Beschreibung_en // .Beschreibung) |
{
      "littlePrinceItem": {
        "title": .Titel,
        "titleInternal": .Intern_Titel,
        "subTitle": .Untertitel,
        "title": .Titel,
        "smallImageUrl": "",
        "largeImageUrl": "",
        "language": .Sprache,
        "isbn13": .ISBN13,
        "publication-country": "Germany",
        "publication-location": "Neckarsteinach",
        "publisher": "Edition Tintenfaß",
        "translator": ."Übersetzer_Autor",
        "year": .Jahr|tostring,
        "acquired-from": "https://editiontintenfass.de",
        "description": .Description,
        "tintenfassId": .Nr
      }
    }
] | sort_by(.littlePrinceItem.tintenfassId|tonumber)'
