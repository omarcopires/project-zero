# Translation catalog

The client loads `client/translations/en.json`, extracted from the compiled English `client.en.qm` in a local installation of the original client. Each JSON entry retains context, source key/ID, comment, and available translation forms. Bootstrap installs the catalog before loading QML.

## Source and reproduction

The source used for the recorded extraction was `D:\Tibia Global\packages\Tibia\bin\client.en.qm` (739,296 bytes; SHA-256 `ea8d9fc576f3cad4b2976f1fa8d52a599ad74c951252c814a6e50e99d0ab3808`). The extraction produced 4,622 entries, all with empty context and one translation form, with no duplicate IDs or empty translations.

```powershell
python tools/extract_qm_catalog.py `
  "D:\Tibia Global\packages\Tibia\bin\client.en.qm" `
  client/translations/en.json
```

The script validates QM blocks and records, preserves plural forms if present, sorts entries deterministically, and records the source hash. It does not change the QM file. A compiled QM may omit unfinished/discarded messages and `.ts` metadata. No other language catalogs were found in that historical inspection, so these entries do not prove coverage of every UI string.
