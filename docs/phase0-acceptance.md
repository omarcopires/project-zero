# Fase 0 — Encerramento documental com ressalvas

Data: 2026-09-17. **Estado: entrega documental concluída com ressalvas, conforme solicitação do responsável para finalizar a etapa.** Não é aceite técnico da toolchain, dos recursos ou do cliente novo. A Fase 1 permanece não iniciada. O [plano-base](project-plan-2026-09-17.md) registra a separação entre o fechamento documental e os gates técnicos por incremento.

## Confirmações e evidências

| Área | Situação confirmada | Limite |
|---|---|---|
| Referência funcional | O responsável relatou compilação, seleção, login e jogo normal e confirmou executáveis nas últimas modificações | Confirmação manual suficiente para registrar o laboratório; não é atestação criptográfica fonte/binário. HEADs reconferidos na verificação de assets |
| Autenticação | Sessão com e-mail/senha; HTTP em `http://127.0.0.1:8080/api/v1/webservice`, reconfirmado pelo responsável e pelo `init.lua` fornecido | Sem nova sondagem ou autenticação pelo agente; desafio 2FA deve impedir continuação no incremento inicial |
| Portas de laboratório | Mundo 15.25 em `localhost:7172`, combinando as confirmações explícitas de host e porta; login TCP 7171 também informado | Não confundir serviço TCP de login com a API HTTP nem introduzir fallback automático |
| Servidor disponível | O responsável informou que deixou o servidor ligado em localhost | Não houve conexão ou verificação de disponibilidade pelo agente |
| Recursos adicionados | O responsável adicionou `assets/` com sprites | Arquivos fornecidos pelo responsável, não criados ou modificados pelo agente; origem/revisão do pacote e correspondência com 15.25 ainda por confirmar |
| Inventário de `assets/` | Enumeração recursiva: 6.248 arquivos, 129.713.352 bytes; 6.241 `.lzma`, quatro `.dat`, dois `.json` e um `.jpg` | Contagem de arquivos, não contagem de sprites individuais nem prova de integridade ou completude |
| Catálogo de assets | JSON completo conferido: 5.090 entradas, todas com arquivo existente; sem referências duplicadas ou caminhos fora da raiz | 11 lacunas de IDs, sem sobreposição; conteúdo comprimido não decodificado. Ver [resultados e hashes](phase0-assets-verification.md) |
| Aparências | Arquivo local com 5.017.898 bytes e SHA-256 correspondente ao nome | Difere do arquivo do servidor, com 4.862.287 bytes; equivalência de IDs não demonstrada, bloqueando aceite de recursos até comparação semântica |
| Toolchain | Seleção aprovada: C++20, Qt 6.11.1 via vcpkg, MSVC 14.51.36231, CMake 4.3.1-msvc1, Ninja e `x64-windows`; detalhes no relatório da Fase 0 | Combinação **ainda não validada**, segundo o responsável; consulta local não resolveu o objeto Git do baseline selecionado |
| Contratos visuais | Login, seleção e parte das dependências transitivas inventariados | Não há implementação, carregamento de QML ou compatibilidade operacional comprovada |

A descoberta de `assets/` atualiza o inventário histórico: não cabe mais tratar sprites e arquivo de aparências como simplesmente não localizados no workspace. Isso não comprova que o pacote esteja completo ou corresponda aos IDs do servidor.

## Dependências transitivas identificadas nesta rodada

Caminhos QML relativos a `qt/qml/qmlcomponents/qml/`, salvo indicação diferente. Inspeção somente leitura, sem fechar o inventário global:

- `TibiaButton.qml:12–14,50–52` consome imagens por `Optimized1PixelBorderImage.qml:12–18`, que constrói URLs do provider `image://optimized1pixelborderimage/` e solicita dimensões por `sourceSize`. Aliases de arquivos sozinhos não implementam esse contrato.
- Moldura de diálogo, botões grey/green, texturas/botões/handles de scrollbar, quatro bordas `1pixel-down-frame`, separadores e indicadores possuem candidatos físicos em `images/`. Correspondência por nome não comprova resolução da URL ou equivalência visual.
- A tabela legada depende de `WheelArea`, instanciado em `qt/qml/QtQuick/LegacyControls/ScrollViewOld.qml:266`; descritores não fornecem a implementação nativa ausente.
- `clientwindow.qml:125` usa `Glow`; a cadeia de efeitos exige implementações privadas como `ShaderBuilder` e `SourceProxy`. Compatibilidade da distribuição Qt selecionada permanece pendente.
- Os comentários de injeção de controller em `TibiaDialog.qml:11–15,25–27` divergem. A composição futura deve atender ao contrato consumido, sem inferir uma implementação nativa a partir dos comentários.
- Família Verdana, traduções, sons efetivos, URLs dinâmicas premium e ownership das instâncias de aparência continuam sem fechamento. O atlas bitmap de 67 caracteres não substitui automaticamente a família usada por `Text`.

## Gates técnicos dos próximos incrementos

Estes itens não foram resolvidos nem dispensados pelo encerramento documental. A implementação do caminho afetado deve parar quando depender de contrato ou recurso não demonstrado.

| Pendência | Critério / responsável | Marco |
|---|---|---|
| Toolchain | Responsável/CI registrar versão do Ninja, disponibilizar e resolver baseline, validar configuração, ABI e build; agente não executa essas operações | Aceite da Fase 1; bootstrap pode ser escrito sem declarar compilação |
| Contrato 15.25 restante | Inspeção estática de capacidades e formato exato antes de escrever o enquadramento ou cada mensagem; fixtures sintéticas e validação externa | Enquadramento da Fase 1 e sessão/MVP seguintes |
| Pacote de assets | Confirmar procedência/revisão e comparar semanticamente os metadados divergentes com os IDs do servidor e catálogo; validar decodificação externamente | Recursos da Fase 3, antes de aparências reais |
| Traduções, fontes e sons | Catálogos não localizados; Verdana presente no Windows, sem prova de métricas/redistribuição; recursos sonoros efetivos não demonstrados. Responsável fornecer recursos autorizados e validar apresentação | Fase 4 |
| Inventário transitivo | Fechar APIs necessárias a cada recorte antes de implementá-lo, incluindo provider dos botões, tipos legados e ownership | Fase 4 |
| Chat | `deslect()`/`deselect()` sem solução compatível demonstrada; preservar frontend e bloquear caminho afetado | Fase 5 |

## Decisão e alcance do encerramento

Após receber a proposta com ressalvas, o responsável solicitou as verificações necessárias e a finalização da etapa, e confirmou localhost e executáveis nas últimas modificações. Esse pedido fundamenta **encerramento da entrega documental**, não uma declaração de aceite técnico ou uma aprovação de resultados executáveis inexistentes.

Entregues: referência e laboratório registrados, fluxo HTTP/sessão/TCP rastreado, matriz inicial do MVP, inventário delimitado de contratos/recursos e seleção de toolchain. As pendências acima passam a gates explícitos dos respectivos incrementos. Não se declara inventário global completo.

A próxima atividade pode ser o bootstrap sem interface da Fase 1. Nenhuma implementação foi iniciada nesta entrega; contratos não documentados não podem ser preenchidos por suposição. Não é necessário solicitar novamente os mesmos dados do laboratório ou o mesmo relato funcional.

## Verificações desta rodada e preservação

Leitura de documentação e QML, catálogo JSON completo, existência/confinamento de referências, faixas de IDs, hashes dos assets e do arquivo de aparências do servidor, busca de fontes/traduções/sons, HEADs das referências e consulta local do objeto de baseline. Detalhes, resultados negativos e limites em [verificação estática](phase0-assets-verification.md).

Não houve descompactação, decodificação de aparências, configuração, geração, compilação, instalação, teste executável, carregamento de QML, conexão ao servidor, commit ou push nesta verificação. Apenas documentação foi escrita. O diff dos caminhos protegidos e de `.clang-format` contra HEAD estava vazio; `assets/` permanece adição não rastreada do responsável, sem stage pelo agente.

Referências: [relatório da Fase 0](phase0-contract-status.md), [recursos iniciais](phase0-initial-resource-contracts.md), [autenticação visual](phase0-authentication-ui-contracts.md), [Fase 1](phase1-bootstrap-transport.md) e [política de validação](validation-policy.md).
