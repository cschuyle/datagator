#!/usr/bin/env bash
jq \
  '.items[].littlePrinceItem | select(.owned != "true") |
  {
    id: .tintenfassId,
    language: .language,
    title: .title,
    description: .description,
    ISBN13: .isbn13
  }' \
  tintenfass-little-prince.json
