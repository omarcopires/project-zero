# Fase 0 — Recursos da composição inicial e seleção

Data: 2026-09-17. Inventário estático parcial, complementar à [auditoria geral](backend-resource-audit.md) e ao [relatório de contratos](phase0-contract-status.md). O [termo](phase0-acceptance.md) registra o encerramento documental com ressalvas, sem integração gráfica iniciada. Atualização: sprites/metadados estão presentes em `assets/`; catálogo, hashes e diferenças frente ao servidor constam na [verificação posterior](phase0-assets-verification.md). Fontes Verdana foram encontradas no Windows, sem validação de métricas; traduções não localizadas. Frontend, ambiente e instalações permanecem intactos.

## Recorte e evidência

Consumidores principais: `clientwindow.qml`, `CharacterSelection.qml` e `OutfitAppearanceInstanceRenderer.qml`, em `qt/qml/qmlcomponents/qml/`. Dependências diretas foram examinadas para identificar requisitos de recursos, modelos e ciclo de vida. Linhas abaixo são localizadores da cópia inspecionada, não contratos estáveis de posição.

**Referência literal, arquivo físico e URL resolvida são evidências diferentes.** Não foi criado manifesto de recursos, plugin, provider, tradutor ou adaptador. Aliases propostos abaixo devem apontar aos originais inalterados, nunca a cópias modificadas.

## Imagens literais do recorte principal

A verificação estática extraiu sete caminhos literais únicos `/images/...` dos três consumidores: cinco correspondem diretamente a arquivos físicos e dois exigem mapeamentos externos. Todos os sete têm um arquivo original candidato; nenhum alias foi registrado ou validado em runtime.

| Referência no QML | Arquivo original existente | Consumidor / consequência |
|---|---|---|
| `/images/title.jpg` | `images/title.jpg` | `clientwindow.qml:49`; fundo da janela |
| `/images/icon-pin.png` | `images/icon-pin.png` | `CharacterSelection.qml:255–339`; indicador de pin |
| `/images/maincharacter.png` | `images/maincharacter.png` | Mesmo intervalo; personagem principal |
| `/images/icon-status-hidden.png` | `images/icon-status-hidden.png` | Mesmo intervalo; estado oculto |
| `/images/unknownoutfit.png` | `images/unknownoutfit.png` | `OutfitAppearanceInstanceRenderer.qml:87`; fallback visual condicionado pelo QML |
| `/images/premium/icon-premium.png` | `images/icon-premium.png` | `CharacterSelection.qml:472–473`; alias externo necessário |
| `/images/premium/icon-nopremium.png` | `images/icon-nopremium.png` | Mesmo intervalo; alias externo necessário |

Correspondência direta no disco também exige que a composição exponha o recurso na URL esperada. A validação não cobre dimensões, conteúdo visual, DPI, resolução relativa à URL-base ou disponibilidade no pacote final.

`CharacterSelection.qml:523–537` obtém imagens de `controller.premiumFeaturesModel` por `modelData.imageUrl`; os valores não podem ser enumerados a partir desse QML. O mesmo modelo fornece `modelData.message`. O adaptador deve definir os recursos e mensagens fornecidos, sem inventar conteúdo remoto ou permitir que uma URL de dados altere arbitrariamente a origem de recursos.

## Dependências além das imagens diretas

| Área | Evidência estática | Contrato / lacuna |
|---|---|---|
| Registro de recursos | `clientwindow.qml:6` importa `qrc:/qt/qml/qmlcomponents/qml`; os dois `qmldir` de `qmlcomponents` declaram plugins e `prefer` | Registrar originais e módulos pela composição Qt. Diretórios no disco não comprovam resolução `qrc:` nem presença de plugins |
| Molduras e controles | `TibiaDialogFrameWithCaption.qml:15`, `TibiaButton.qml:13–14`, `TibiaTableView.qml:53–68` usam `/images/skin/classic/...` | Há correspondentes físicos como `images/dialog-frame-borderimage.png` e `images/scrollbar-texture-vertical.png`. Inventário de sete imagens acima não cobre toda essa árvore transitiva |
| Recompensa diária | `TibiaDailyRewardStatus.qml:7–27` relaciona estados `TibiaEnums.DailyRewardState*` a imagens `icon-dailyrewarddone.png`, `icon-dailyrewardready.png`, `icon-dailyrewarddeactivated.png` e IDs de tradução | Preservar relação entre estado, ícone e texto; não inferir valores numéricos do enum por seus nomes |
| Fonte de texto | `TibiaTextBase.qml:11–15` usa `TibiaStyle.defaultTextFont`; `TibiaStyle.qml:95–116` especifica família `Verdana` e tamanhos | Disponibilidade da família e métricas no ambiente de execução ainda não demonstradas; não modificar a fonte do QML para ocultar ausência |
| Atlas bitmap | `images/Verdana10px.fnt:3` aponta a `/fonts/Verdana10px.png`; existe `images/Verdana10px.png` | Alias já identificado na auditoria geral. Consumo desse atlas pelo recorte não demonstrado; atlas bitmap não substitui automaticamente a família usada por `Text` |
| Tradução | `clientwindow.qml:91–95`, `CharacterSelection.qml:9` e `OutfitAppearanceInstanceRenderer.qml:93` usam `qsTrId` | Exemplos: `startscreen_please_wait_*`, `characterselection_caption`, `characterselection_no_outfit_tooltip`. Busca anterior não localizou catálogos `.qm`/`.ts` visíveis; catálogo, cobertura e instalação do tradutor continuam pendentes |
| Serviços auxiliares | `TibiaButton.qml:100–105` chama `SoundHelper.playSound`; `TibiaDialog.qml:124` usa `tibiaMouseCursorController`; `TooltipBase.qml` usa `TooltipHelper`, watcher e overlay | Serviços e ciclo de vida não são resolvidos com aliases de imagens. Recursos sonoros e implementação dos serviços não demonstrados |

## Modelos, aparências e ownership

### Composição e controller

- `clientwindow.qml:58–59` considera o carregamento concluído quando há filhos no contêiner. O `placeholder` em `:113–120` recebe a composição interna; esse arquivo não demonstra quem cria e destrói a seleção. Existência de um filho não significa prontidão de sessão, modelo ou renderização.
- `CharacterSelection.qml:12–44` exige `QtObject controller`, estados premium/outfits/recuperação, busca e confirmação por índices de linhas. Ordenação, pin, filtros e ações de conta/premium também pertencem ao contrato, mesmo quando fora do MVP funcional.
- O adaptador de apresentação deve manter controller/modelos válidos enquanto o diálogo os consome e publicar notificações na thread apropriada. A composição é responsável por injeção e encerramento; domínio e casos de uso não conhecem caminhos QML, `QObject`, texturas ou plugins.
- Não simular sucesso de ações não implementadas. A política de indisponibilidade deve respeitar as APIs existentes; quando não houver adaptação compatível, registrar o bloqueio do caminho afetado.

### Modelo de personagens

`CharacterSelection.qml:206–442` exige roles `outfit`, `characterName`, `dailyRewardState`, `level`, `vocation`, `world`, além de acessos a `modelData.isPinned`, `isMainCharacter`, `isHidden`, `worldRules`, dados internos de `outfit`, `model.length` e `lastSelectedIndex`.

`qt/qml/QtQuick/LegacyControls/TableViewItemDelegateLoader.qml:82–97` distingue `model[role]` de `modelData[role]`. Expor apenas roles em um `QAbstractItemModel` não demonstra atendimento completo. A futura adaptação deve definir uma representação consumível pela tabela legada, notificar alterações e manter coerência entre índices visíveis, ordenação/filtros e identidade do personagem. Não tratar índice como identificador estável de domínio.

### Instâncias de aparência

`OutfitAppearanceInstanceRenderer.qml:6–82` exige `AppearanceInstanceRenderer`, `OutfitAppearanceInstance`, `ObjectAppearanceInstance`, `OutfitAppearanceInstance.SOUTH`, animação, centralização, filtragem e a lista `appearanceInstances`.

A função `reloadOutfitAppearance()` cria objetos com parent `outfitRenderer`, configura `typeid`, cores, addons, direção e movimento e substitui a lista de instâncias. Um timer de intervalo zero agrupa atualizações. A função não destrói explicitamente as instâncias anteriores; a semântica do setter nativo ausente não foi demonstrada. Isso é uma lacuna de ownership, não um vazamento reproduzido.

O contrato nativo futuro deve definir propriedade e descarte das instâncias, referências mantidas pela renderização e encerramento seguro entre threads. Não destruir objetos ainda referenciados nem acumular filhos a cada atualização. Metadados de aparências e texturas devem ser geridos pela infraestrutura de recursos/renderização, sem expor esses detalhes ao domínio.

O fallback `unknownoutfit.png` é acionado pelas condições existentes no QML; não fornece sprites nem comprova disponibilidade de outfits. Catálogo de aparências, sprites e correspondência de IDs continuam requisitos próprios, já na seleção de personagens.

## Critérios futuros de validação externa

Não executados nesta etapa; reservados ao responsável/CI, quando houver implementação:

1. Resolver imports e URLs para originais inalterados, incluindo aliases premium e de controles; verificar ausência de colisões com recursos Qt.
2. Carregar a composição com tipos e serviços reais, sem substituir componentes ou esconder dependências obrigatórias por invisibilidade.
3. Validar traduções, fontes e métricas; distinguir IDs não traduzidos e fonte substituta de apresentação correta.
4. Exercitar lista vazia, filtro, ordenação e seleção, verificando identidade correta e notificações após mudanças do modelo.
5. Repetir mudanças de aparência e fechamento/reabertura, verificando ownership, descarte e sincronização sem referências inválidas.
6. Comparar apresentação e DPI apenas com sprites/metadados efetivamente disponíveis; não declarar fidelidade com base no fallback.

## Resultado e próximos dados necessários

O mapeamento literal dos três consumidores está concluído no limite descrito. Permanecem abertos: aliases transitivos completos, URLs dinâmicas do modelo premium, catálogos de tradução, disponibilidade de fontes, sprites/metadados/IDs e contratos nativos de lifecycle. Nenhum desses itens foi suprido por modificação do frontend.

Verificações realizadas: leitura de fontes e descritores, conferência dos sete caminhos literais e candidatos físicos, busca textual em QML/JS. A busca ampla por `qrc:/`, `image:`, `font:` ou `Translator` serviu somente à descoberta; não é um parser de QML, teste de cobertura de recursos ou prova de ausência de referências dinâmicas. Nenhum build, instalação, carregamento de QML, conexão ao jogo ou teste executável foi realizado.
