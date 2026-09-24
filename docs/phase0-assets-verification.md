# Fase 0 — Verificação estática dos assets

Data: 2026-09-17. Inspeção somente leitura; complementa o [encerramento documental](phase0-acceptance.md). Não é validação de decodificação, compatibilidade 15.25 ou execução gráfica.

## Método e resultados

PowerShell 5.1: enumeração recursiva, `ConvertFrom-Json`, resolução confinada dos caminhos do catálogo, `Test-Path`, ordenação numérica das faixas e `Get-FileHash -Algorithm SHA256`. Nenhum código do projeto foi executado. A primeira tentativa de enumeração JSON falhou por encapsular o array; foi corrigida antes de obter os resultados abaixo. A busca por extensões foi repetida com filtro explícito, pois `-Include` não restringiu a enumeração como esperado.

| Verificação | Resultado |
|---|---|
| Arquivos em `assets/` | 6.248; 129.713.352 bytes |
| Extensões | 6.241 `.lzma`, quatro `.dat`, dois `.json`, um `.jpg` |
| Catálogo completo | JSON parseável; 5.090 entradas |
| Tipos de entrada | 5.084 `sprite`; uma de cada: `appearances`, `staticdata`, `staticmapdata`, `fullmap`, `map`, `proficiencies` |
| Caminhos | Nenhum vazio, absoluto, com escape por `..` ou fora da raiz no conjunto examinado |
| Referências | Todas as 5.090 apontam a arquivos existentes; nenhum nome de arquivo referenciado repetido |
| Arquivos fora do catálogo | 1.157, desconsiderando o próprio catálogo: 207 `minimap`, 741 `satellite`, 209 `subarea` |
| Faixas de sprites | Primeiro ID 0, último 301200; nenhuma faixa invertida/negativa ou sobreposição; 11 lacunas globais |
| SHA-256 versus sufixo do nome | Coincide nos seis arquivos auxiliares; difere nos 6.241 `.lzma`; catálogo sem hash no nome |

SHA-256 calculado do catálogo: `6156366d9489d20bf2ec330f2365f3b328e36cbd57cdcdeba01706259e83765b`.

Lacunas globais inclusivas: `2664–3346`, `142046–193959`, `195091–195195`, `195293–195321`, `195381–195386`, `196615–197224`, `197715–197845`, `197903–197908`, `242711–264776`, `268767–269815`, `273832–274739`.

Lacunas não demonstram arquivos faltantes: todas as referências presentes no catálogo foram encontradas. IDs podem não ser utilizados; isso depende da análise dos metadados. Arquivos não referenciados também não são classificados como lixo e não devem ser removidos.

Os hashes foram calculados sobre os bytes armazenados, inclusive a compressão. Não foi estabelecido se o sufixo de nome dos `.lzma` identifica conteúdo descomprimido ou outra representação. Portanto, a divergência **não é prova de corrupção**, e a coincidência dos auxiliares **não autentica a procedência**. Não houve descompactação nem comparação com manifesto externo confiável.

## Comparação com aparências do servidor

| Arquivo | Bytes | SHA-256 calculado |
|---|---|---|
| `assets/appearances-063e8d11a76a6f95bd986812808b52db4158a05601e7ea5cf0cb688fa9e36d57.dat` | 5.017.898 | `063e8d11a76a6f95bd986812808b52db4158a05601e7ea5cf0cb688fa9e36d57` |
| `E:\caverot-server\data\items\appearances.dat` | 4.862.287 | `aa44a154f30c7ed59acc25f246286396e4043851ef0b54ef3cf3951e46d1ce50` |

Os arquivos não são idênticos. Não foram decodificados; a diferença não determina quais IDs ou propriedades divergem, nem prova incompatibilidade de todos os recursos. **Gate de recursos:** antes da integração de aparências/mundo, estabelecer correspondência entre metadados do servidor, catálogo e sprites, incluindo IDs efetivamente usados. Não substituir nenhum dos arquivos por suposição.

## Fontes, traduções e sons

Busca de nomes/extensões no workspace, excluindo `.git`, não localizou `.qm`, `.ts`, `.ttf`, `.otf` ou `.ogg`. Encontrou apenas `images/empty.wav` (132 bytes) no conjunto de extensões sonoras consultado. Não houve abertura de dumps ou sons. Essa busca não descarta traduções embutidas ou outros formatos.

No diretório de fontes do Windows foram encontrados `verdana.ttf` (243.304 bytes), `verdanab.ttf` (211.260), `verdanai.ttf` (223.268) e `verdanaz.ttf` (229.800). Isso confirma arquivos locais, não seleção efetiva pela aplicação, métricas corretas, direito de redistribuição ou disponibilidade em outra máquina. Não copiar fontes do sistema para o projeto.

Traduções, sons efetivos e empacotamento de fontes permanecem gates da integração visual. O atlas bitmap existente não substitui automaticamente a família usada por `Text`.

Atualização de 2026-09-24: o conjunto de recursos está no workspace em `things/assets/`, incluindo `catalog-content.json` e o `appearances-*.dat` referenciado por ele. Os schemas Protobuf correspondentes fornecidos pelo responsável estão em `client/protobuf/appearances.proto` e `client/protobuf/shared.proto`. O cliente agora gera as classes C++ desses schemas e introduz um catálogo que lê os quatro grupos e indexa IDs/flags por categoria. O responsável informou 132/132 testes após essa implementação; ainda não há caso dedicado de leitura do arquivo real nem comparação semântica das entradas com as aparências do servidor. A diferença de hashes registrada acima continua sendo apenas uma diferença entre arquivos, não prova de incompatibilidade total.

## Referências e ambiente

HEADs consultados novamente, sem mudança em relação ao registro anterior:

- Servidor: `c7c8337842da610ff7c6569235d781c9276b7287`.
- Cliente de referência: `02e0ae82693cbb7036983329d03246157947a751`.

O responsável confirmou que os executáveis correspondem às últimas modificações. O relato é aceito como confirmação manual do laboratório, não como atestação criptográfica fonte/binário. Não foi necessário pedir novamente confirmação de login/jogo.

A consulta local `git cat-file -t` não conseguiu resolver o objeto do baseline selecionado `fa8cecf91d7f31a1715a7a6524f208897ffb33ce` em `D:\vcpkg`. Isso registra indisponibilidade nessa consulta, não erro no baseline publicado. Não houve fetch, troca de checkout ou instalação; resolução futura cabe ao responsável/CI. Versão do Ninja e compatibilidade executável continuam não verificadas.

## Preservação e limites

O diff contra HEAD dos caminhos protegidos e de `.clang-format` não apresentou alterações. Essa verificação Git não substitui auditoria criptográfica integral ou inventário de arquivos ignorados. `assets/` permanece adição do responsável, sem stage ou alterações pelo agente.

Não houve build, configuração, geração, instalação, execução de testes/cliente/servidor, requisição HTTP, conexão TCP, commit ou push nesta verificação.
