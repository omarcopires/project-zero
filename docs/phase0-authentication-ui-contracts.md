# Fase 0 — Contratos visuais de autenticação

Data: 2026-09-17. Inspeção estática complementar ao [relatório da Fase 0](phase0-contract-status.md). Não implementa autenticação nem comprova o carregamento dos componentes. Caminhos QML abaixo são relativos a `qt/qml/qmlcomponents/qml/`.

## Evidência nova: segundo fator por e-mail

`TwoFactorEMailTextEnterDialog.qml` existe no frontend original. A chave `request_two_factor_email_code_request_new_code_button_tooltip` em `:89` evidencia a finalidade de solicitar novo código por e-mail. Isso refina a lacuna anterior: há um componente específico, mas sua criação e associação ao fluxo de login não foram demonstradas.

| Superfície observada | Contrato QML | Responsabilidade futura |
|---|---|---|
| Controller (`:16,26–35`) | `QtObject controller`; `onOkClicked(text)`, `onCancelClicked()` | Adaptador encaminha intenções ao caso de uso da tentativa atual; não implica sucesso ou fechamento automático |
| Entrada (`:17–24,54–67`) | Aliases `description`, `maxInputLength`, `enteredText`; flag `intOnly` | Composição configura propriedades do item. Não presumir propriedades homônimas no controller |
| Validador (`:59–65`) | Quando `intOnly`, expressão `/[0-9]{0,9}/` | Restrição de caracteres não valida código, expiração ou comprimento obrigatório. Tratar código como texto, preservando zeros iniciais |
| Ação adicional (`:20–22,85–89`) | `buttonDescription`, `buttonVisible`; `onButtonClicked()` | Intenção associada visualmente ao reenvio por e-mail; elegibilidade, prazo e resultado pertencem ao caso de uso/serviço |
| Informação (`:23–24,69–75`) | `additionalInfo`, `additionalInfoTextVisible` | Adaptador publica informação adequada ao estado, sem inserir segredos ou conteúdo remoto arbitrário |
| Confirmação/cancelamento (`:97–106`) | Botões encaminham aos mesmos callbacks de teclado | Sem bloqueio local demonstrado de solicitações repetidas; requer controle de concorrência na camada interna |

O caption inicial é genérico. Não há prova de qual composição define título, descrição, comprimento e visibilidade. Não inferir suporte a autenticador/TOTP, dispositivo confiável ou recuperação a partir desse diálogo de e-mail.

## Entrada de credenciais e estados visuais

| Consumidor / linhas | Comportamento observado | Limite do contrato |
|---|---|---|
| `gamewindow.qml:84–114` | `loginClicked()` chama `controller.loginPressed(email, password)` fora de `INGAME`, com controller e campos não vazios; depois chama `clearLoginMask()` | Início de uma intenção, não confirmação de autenticação. Limpeza da string visual não demonstra apagamento de todas as cópias na memória |
| `gamewindow.qml:140–165` | Enter/Return tentam login; Cancel/Escape apenas chamam `clearLoginMask()`; `gameWindowState` alimenta o estado visual | Escape no formulário não é comando de cancelamento da operação de rede |
| `gamewindow.qml:464–543` | `isAuthenticated`, `showCreateAccountOption`, `goToLogin()`, `goToCreateNewAccount()` | Visibilidade de painéis não é evidência de ingresso no mundo nem máquina de estados completa |
| `gamewindow.qml:582–680` | `initialLoginEmail`, leitura/escrita de `rememberEmail` e `showEmailAsPlainText`; recuperação por `forgotEMailAddressOrPasswordPressed()`; senha com `TextInput.Password` | Persistência e destino da recuperação não demonstrados. Indicação visual de `@` não é condição de `loginClicked()` |
| `gamewindow.qml:100–105,693–727` | `handleCreateNewAccount()`, `createAccountEnabled`, `isCapsLockActive` | Ações e estados externos exigem adaptação própria, sem simular sucesso |
| `CharacterSelection.qml:12–34,582–592` | `onCharacterSelectionConfirmed(indices)` e `onCancelClicked()` | Seleção/cancelamento visual não comprovam criação ou encerramento da conexão ao mundo |

O QML não impede, no corpo de `loginClicked()`, uma segunda tentativa enquanto a primeira está pendente. A futura coordenação deve definir rejeição ou substituição explícita, sem permitir que resposta tardia de uma tentativa anterior autentique a tentativa atual. Isso é requisito de projeto, não falha reproduzida.

## Componentes genéricos: não atribuir usos não demonstrados

| Componente | Contrato observado | Cautela |
|---|---|---|
| `GenericEnterTextDialog.qml:8–30,47–64,80–90` | Controller fornece `caption`, `intOnly`, `dialogWidth`, `description`, `maxInputLength`, `enteredText`, `readOnly`, **`confirmLable`**, `onOkClicked(text)`, `onCancelClicked()` | Preservar grafia legada. Conversão `Number(...).toString(10)` no texto inicial numérico pode remover zeros iniciais; não pressupor adequação para códigos |
| `TibiaMessageDialog.qml:9–40,115–127` | Propriedades do item para mensagem, checkbox e botões (`label`, `identifier`); callbacks `onDialogReturnKeyPressed()`, `onDialogEscapeKeyPressed()`, `onDialogKeyPressed(key, modifier)`, `onDialogButtonClicked(identifier, checked)` | Apresenta mensagens genéricas; mapeamento dos erros de login ainda ausente |
| `TibiaMessageDialog.qml:17–26,69–87` | `MessageDialogController` em `qmlenumvalues` seleciona formato de texto; links acionam `Qt.openUrlExternally(link)` | Tipos e enums nativos são dependências. Para erros não confiáveis, usar apresentação em texto simples pela API existente; não encaminhar HTML/links arbitrários ao diálogo |
| `GenericConfirmWithDontShowAgainDialog.qml:6–25,48–52` | Textos, `showThisDialogAgain`, `onYesClicked(!checked)`, `onNoClicked()` | Preferência genérica de exibição não comprova confiança de dispositivo ou armazenamento de sessão |
| `WaitDialog.qml:7–18,29–46,56–61` | Controller fornece `dialogCaption`, `dialogText`, `fillPercentage`, `waitTextWithRemainingDuration`; botão/teclado chamam `abortWait()` | Não implementa contagem regressiva, fila de login, reconexão ou cancelamento do transporte |

`TibiaDialog.qml` é uma base inicialmente invisível, com encaminhamento de teclado e foco. Seus comentários de injeção de controller não demonstram uma implementação nativa. Não presumir que cancelar fecha ou destrói automaticamente o diálogo.

A animação “please wait” de `clientwindow.qml:56–121` depende de filhos no contêiner de composição, não de autenticação. Não usá-la como evidência de progresso da rede.

## Responsabilidades e invariantes do backend futuro

- **Casos de uso:** separar credenciais submetidas, desafio pendente, autenticação concluída, lista disponível e ingresso no mundo. Erro, expiração e cancelamento não se convertem em sucesso visual.
- **Correlação:** cada callback precisa pertencer à tentativa/desafio vigente. Cancelamento invalida respostas tardias; reenvio deve seguir a semântica confirmada do serviço, sem assumir que código antigo continue válido ou seja invalidado.
- **Adaptadores Qt:** preservar nomes e separar propriedades do item das propriedades do controller. Atualizar na thread apropriada, manter lifetime explícito e desconectar callbacks antes de descartar objetos.
- **Composição:** criar/configurar/exibir os originais e manter seus controllers enquanto forem consumidos. A criação dinâmica de diálogos não pode ser inferida de sua mera existência.
- **Privacidade:** não registrar senha, código, sessão ou conteúdo integral das respostas. Não persistir código de segundo fator nem tratá-lo como número. Preferência de lembrar e-mail não autoriza persistência de senha.
- **Falhas apresentadas:** converter resultados internos em mensagens controladas; não copiar resposta remota para rich text nem classificar toda falha como credencial inválida.

Esses requisitos orientam implementação posterior; não definem payloads, endpoints, assinaturas C++ ou valores de enum por suposição. Domínio/casos de uso permanecem independentes de Qt/QML e transporte concreto.

## Critérios futuros do responsável/CI

Nenhum cenário executado nesta etapa:

1. Entrada vazia, tentativa repetida e resposta fora de ordem: nenhuma autenticação implícita ou aplicação de resultado obsoleto.
2. Código textual com zero inicial, vazio, inválido e expirado: contrato do serviço respeitado, sem conversão numérica no adaptador.
3. Reenvio e cancelamento durante desafio: um resultado terminal por tentativa; callbacks de diálogo descartado não são utilizados.
4. Escape no formulário versus Cancel no diálogo: verificar os comportamentos distintos, sem afirmar cancelamento de rede onde só existe limpeza visual.
5. Erros de transporte, autenticação e expiração: mensagens controladas, sem segredos ou links remotos arbitrários.
6. Abrir/fechar/reabrir: controller, foco e objetos válidos; nenhuma alteração dos originais.

## Cobertura e bloqueios restantes

A busca filtrada em `**/*.{qml,js}` do workspace, respeitando exclusões do editor, não revelou a instanciação desses diálogos por seus nomes, nem contrato específico de autenticador/TOTP ou dispositivo confiável. Não é prova de ausência na implementação original: a orquestração pode ser nativa e não está disponível aqui.

O frontend contém o diálogo de e-mail; **não está demonstrado que o segundo fator efetivo do servidor usa esse canal**. Antes de integrar o caminho, confirmar correspondência de estados. Não adaptar um desafio de outra natureza silenciosamente para e-mail.

O responsável confirmou builds atuais, autenticação por sessão com e-mail/senha e login em `http://127.0.0.1:8080/api/v1/webservice`. Informou que existe 2FA, mas que não é necessário implementá-lo inicialmente. O primeiro incremento deve rejeitar explicitamente a continuação de um desafio não suportado, sem ignorá-lo ou apresentar sucesso. Os cenários de entrada/reenvio de código acima ficam para o incremento posterior; o tratamento seguro de desafio não suportado pertence ao inicial.

Endereço/porta TCP do jogo e identificação exata dos binários no registro externo continuam pendentes. Não é necessário repetir as confirmações já recebidas nem fornecer senhas, códigos, tokens, configurações completas, logs reais ou dumps. A Fase 1 continua não iniciada; runtime e aceite da Fase 0 não são substituídos por esta inspeção.
