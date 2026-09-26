# Catálogo de traduções

O cliente consome `client/translations/en.json`, extraído do catálogo inglês
compilado `client.en.qm` presente na instalação local do cliente original. O
JSON guarda cada entrada por contexto, chave de origem/ID, comentário e todas as
formas de tradução disponíveis. O bootstrap instala esse catálogo antes de
carregar o QML.

## Origem e extração

Origem verificada: `D:\Tibia Global\packages\Tibia\bin\client.en.qm`.

- Idioma: `en`.
- Tamanho: 739.296 bytes.
- SHA-256: `ea8d9fc576f3cad4b2976f1fa8d52a599ad74c951252c814a6e50e99d0ab3808`.
- Entradas extraídas: 4.622, todas com contexto vazio e uma forma de tradução.
- IDs repetidos ou traduções vazias na extração: nenhum.

Para repetir a extração a partir de outra instalação, mantendo o catálogo em
formato estável:

```powershell
python tools/extract_qm_catalog.py `
  "D:\Tibia Global\packages\Tibia\bin\client.en.qm" `
  client/translations/en.json
```

O script valida os blocos e registros do formato QM, preserva as formas plurais
caso existam, ordena as entradas de maneira determinística e registra o hash da
origem. O arquivo fonte original não é alterado.

## Limites do QM compilado

Esta é uma extração integral das entradas efetivamente publicadas nesse arquivo,
não do projeto-fonte de traduções. Um QM não contém necessariamente mensagens
inacabadas ou descartadas na compilação, nem todos os metadados de um arquivo
`.ts` original. Também não foram encontrados catálogos de outros idiomas. Assim,
as 4.622 entradas são o mapa completo disponível no `client.en.qm`, mas não
provam cobertura de todas as strings existentes no cliente.
