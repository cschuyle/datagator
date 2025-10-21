#!/usr/bin/env bash
cat "$1" | jq \
  '.items[].littlePrinceItem |
  {
    id: .tintenfassId,
    language: .language,
    title: .title,
    ISBN13: .isbn13
  }'
