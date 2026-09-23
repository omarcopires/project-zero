# Fase 2 — Contrato inicial de autenticação

Data: 2026-09-22. Cliente de referência em `d4ae7cf2dc058d82bc375faf44c6eecc3dd9fa84`; servidor em `f42413eff8d59b04087b52d1b793a4c685de5a82`.

O cliente envia JSON por POST com `type=login`, e-mail, senha, versão e estado de segundo fator. O servidor local aceita o fluxo inicial sem cadastro de TOTP quando `twoFactorAction=skip`. Isso não contorna uma conta já protegida: nesses casos o servidor retorna `errorCode=6`; oferta de cadastro retorna `errorCode=7` e `twoFactorSetup`. Ambos são classificados como desafio não suportado no primeiro incremento e nunca produzem sessão.

O sucesso exige objetos `session` e `playdata`, sessão ativa com `sessionkey`, ao menos um mundo válido e ao menos um personagem associado por `worldid`. O endpoint do mundo usa os campos externos não protegidos confirmados para o laboratório, com fallback para as variantes protegida e genérica presentes no contrato de referência.

Mensagens remotas de erro são classificadas, mas não atravessam diretamente para rich text ou logs. Senha, chave de sessão, tokens e corpo integral nunca são registrados. Este incremento implementa somente codificação e interpretação determinísticas com dados sintéticos; não envia credenciais nem autentica no laboratório.

Validação externa de 2026-09-22: após a correção de uma asserção que ainda usava a API de `QString` sobre um contrato migrado para `std::string`, o responsável informou `100% tests passed, 0 tests failed out of 51`. Os oito testes deste incremento cobrem requisição mínima, credenciais vazias, sucesso completo, rejeição de autenticação, os dois formatos de desafio TOTP, JSON malformado e sucesso incompleto.

## Coordenação de tentativas

A máquina de estados interna usa identificadores monotônicos e permite uma única tentativa ativa. Cancelamento encerra a tentativa corrente; qualquer resposta posterior ou pertencente a identificador anterior é ignorada. Uma nova tentativa limpa sessão e falha anteriores. Sucesso, credencial rejeitada, desafio não suportado, resposta incompatível, timeout e falha de transporte permanecem resultados distintos. O núcleo não depende de Qt, sockets ou logging e não armazena credenciais.

Validação externa de 2026-09-22: o responsável informou `100% tests passed, 0 tests failed out of 60`. Os nove testes adicionais cobrem IDs monotônicos, concorrência, sucesso, credencial rejeitada, desafio não suportado, resposta incompatível, cancelamento, resposta antiga e distinção entre timeout e falha de transporte.

## Composição assíncrona

O adaptador de aplicação compõe codec, coordenador e transporte HTTP. Ele não registra corpo, credenciais ou sessão; publica somente mudanças de estado. Cancelamento encerra primeiro a tentativa no núcleo e depois aborta a operação HTTP, de modo que o callback de cancelamento não possa substituir o estado terminal. Os testes de integração usam exclusivamente credenciais e respostas sintéticas em loopback.

Validação externa de 2026-09-22: após substituir uma macro GoogleTest usada por engano no harness Qt Test, o responsável informou `100% tests passed, 0 tests failed out of 67`. Os sete testes de integração adicionais cobrem sucesso sintético, credencial rejeitada por resposta HTTP, desafio não suportado, resposta incompatível, timeout, cancelamento e tentativa concorrente.

## Seleção de personagem

A seleção aceita somente um nome presente uma única vez na sessão autenticada e resolve exatamente um mundo pelo `worldId`. Mundo ausente ou duplicado e endpoint vazio ou sem porta são falhas explícitas. O destino resultante reúne personagem, mundo, host, porta e chave da sessão vigente para o futuro handshake TCP. Atualizar ou limpar a sessão invalida imediatamente qualquer seleção anterior.

Validação externa de 2026-09-23: o responsável informou `100% tests passed, 0 tests failed out of 76`. Os nove testes adicionais cobrem ausência de sessão, seleção válida, personagem inexistente ou duplicado, mundo ausente ou duplicado, endpoint inválido e invalidação por troca ou falha de sessão.
