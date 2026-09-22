# Fase 1 — Contrato do envelope 15.25

Data: 2026-09-22. Inspeção estática das referências locais, sem conexão, captura de tráfego ou execução. Cliente de referência em `d4ae7cf2dc058d82bc375faf44c6eecc3dd9fa84`; servidor em `abd950f2b6999b4790b09178bfb5f8a4b1272740`.

## Envelope externo confirmado

O perfil corrente do servidor é `CurrentModern`. Cada frame começa com um inteiro little-endian de 16 bits. Esse valor não representa bytes diretamente: o tamanho do corpo é calculado como `blockCount * 8 + 4`.

Evidências convergentes:

- `server/network/protocol/protocol_profile.cpp`: `CurrentModern` usa `ModernBlockCount`, `modernLengthExtraBytes = 4`, sequência nos dois sentidos, payload moderno com byte de padding e compressão oficial.
- `server/network/protocol/transport_codec.cpp`: `decodeBodySize()` multiplica o campo por `XTEA_MULTIPLE` (8) e soma quatro; `encodeOutbound()` realiza a operação inversa.
- `framework/net/packetreadpolicy.h` e `framework/net/outputmessage.cpp` do cliente: leitura calcula `wireSize * 8 + 4`; escrita usa `(messageSize - 4) / 8`.
- Tipos de leitura/escrita das duas referências armazenam os inteiros em ordem little-endian no Windows atual; o cliente usa explicitamente `readULE16`/`writeULE16`.

O framing implementado nesta etapa trata somente `[blockCount:u16 LE][body]`. Os quatro bytes adicionais fazem parte do corpo e correspondem à sequência/checksum na camada moderna. O framing não interpreta sequência, compressão, padding ou XTEA.

## Limites direcionais

Os limites não são simétricos:

- Servidor → cliente: o servidor limita `NETWORKMESSAGE_MAXSIZE` a 65.500 bytes. Esse valor é representável exatamente por `blockCount = 8.187`.
- Cliente → servidor: `Connection::parseHeader()` rejeita corpo maior que `INPUTMESSAGE_MAXSIZE`, fixado em 4.096 bytes. Como o formato só representa tamanhos congruentes a quatro módulo oito, o maior corpo válido nesse sentido é 4.092 bytes (`blockCount = 511`).
- O campo de 16 bits não pode ser multiplicado em aritmética estreita. A implementação promove para `size_t` antes do cálculo e rejeita o limite antes de copiar ou alocar o corpo.

## Semântica incremental

- Menos de dois bytes: aguardar o restante do cabeçalho.
- Cabeçalho completo e corpo parcial: informar o total necessário sem consumir bytes.
- EOF vazio: encerramento limpo.
- EOF com cabeçalho ou corpo parcial: erro de truncamento.
- Frame completo: retornar uma visão sem cópia do corpo e o total consumido, permitindo processar frames concatenados.
- Escrita: aceitar somente corpos de no mínimo quatro bytes, alinhados segundo `(bodySize - 4) % 8 == 0` e dentro do limite de entrada do servidor.

## Camadas deliberadamente posteriores

O perfil corrente também confirma sequência de 32 bits, bit alto de compressão, XTEA, byte frontal de quantidade de padding e raw deflate por pacote. Essas transformações são posteriores ao envelope externo e não foram implementadas neste incremento. Login inicial e transição para o estado criptografado exigem contrato próprio; nenhum payload real foi produzido ou enviado.
