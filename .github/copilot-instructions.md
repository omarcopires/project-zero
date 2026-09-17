# Diretrizes para agentes — novo cliente

## Regras obrigatórias

- Comunique-se em português. Escreva código novo, identificadores, comentários e mensagens internas em inglês. Documentação de projeto pertence a `docs/`.
- Não atribua marca ou nome próprio fixo ao projeto. Use nomes descritivos de responsabilidade em pastas, arquivos, namespaces, alvos CMake, manifesto e executáveis (ex.: `client`, `transport`, `protocol`, `diagnostics`, `unit_tests`), sem prefixos derivados do nome do repositório ou de referências externas. Caminhos históricos e contratos legados permanecem intactos; não renomeie a raiz do workspace.
- **Nunca altere o frontend original do jogo.** Preserve byte a byte `data/`, `images/`, `qt/`, `qt-project.org/`, `qtwebchannel/`, `spells/` e `message.txt`. Não editar, formatar, normalizar finais de linha, renomear, mover, excluir, converter ou substituir os componentes e recursos existentes nessas árvores. Não gerar arquivos nelas.
- Não contorne essa regra com cópias modificadas, patches de build, substituição em runtime ou componentes de mesmo nome que mudem o comportamento do frontend. Não converter QML para OTUI. Corrigir incompatibilidades somente no motor novo, adaptadores Qt, modelos, tipos registrados, providers e mapeamentos externos de recursos. Se não for possível preservar o contrato, interrompa a implementação afetada e registre o bloqueio; não altere o QML.
- **Agentes nunca executam configuração, geração, compilação, linkedição, rebuild ou limpeza de build.** Não executar CMake, presets, Ninja, MSBuild, Make ou wrappers equivalentes para essas operações, mesmo com artefatos existentes ou pedido genérico de validação. Não executar instalação vcpkg que possa compilar dependências.
- Não executar CTest, testes compilados, cliente, servidor ou scripts que iniciem build. Build e validação executável ficam com o responsável ou CI previamente configurada. Não disparar pipelines nem delegar operações proibidas a subagentes, tarefas ou outros mecanismos.
- Permissões de escrita não são autorização para executar build. É permitido escrever testes/configurações quando solicitados; isso não autoriza executá-los. Validações permitidas: leitura, inspeção de diff, hashes, diagnósticos do editor e verificações estáticas sem geração/build e sem execução de código do projeto.
- Preserve mudanças do usuário e a configuração `.clang-format`. Não faça limpeza, instalação, commit, push ou publicação sem solicitação específica. Não leia/exponha segredos ou dumps por conveniência.

## Projeto e engenharia

- Núcleo novo em C++/Qt 6, CMake e vcpkg; Windows inicialmente. Suporte **exclusivo a 15.25** do servidor de desenvolvimento, sem compatibilidade automática com versões antigas ou futuras. OTClient é referência, não núcleo adotado.
- Antes de editar, identifique responsabilidade, contratos, ownership e direção das dependências. Todo backend novo segue **Clean Architecture**: domínio e casos de uso independem de infraestrutura, transporte, persistência, logging concreto e apresentação; adaptadores dependem dos contratos internos, nunca o contrário. Composição e injeção explícita ficam na borda da aplicação.
- Aplique **Clean Code**: responsabilidade única, nomes descritivos, funções coesas, invariantes explícitas, baixo acoplamento e testes determinísticos. Não criar abstrações sem consumidor, classes genéricas de utilidades ou camadas que apenas repassem chamadas.
- Logging padrão obrigatório: **spdlog**, encapsulado na infraestrutura e configurado na composição. Reproduzir o [formato verificado da referência](../docs/coding-standards.md#formato-verificado-na-referência): data/hora com milissegundos, logger descritivo, nível e `[FunctionName] - Message`; interpolação com `{}`, nunca `%d`/`%s`. Tokens `%` do pattern spdlog permanecem. Não expor tipos/headers spdlog ao domínio ou aos casos de uso, nem criar singleton global de logging. Versão fixada pelo manifesto/baseline na implementação autorizada; não instalar dependências nesta etapa documental.
- Cada enum novo deve ser `enum class` em header próprio, nomeado pelo tipo e localizado no módulo responsável. Não reunir enums em arquivo genérico nem declará-los dentro de classes ou headers não relacionados. Adaptações exigidas pelo contrato Qt/QML ficam isoladas e documentadas sem modificar os originais.
- Novos adaptadores devem implementar as APIs exigidas pelo frontend, incluindo nomes legados. A regra de modernização não autoriza remover esses contratos. Não impor novas convenções aos originais.
- Código novo segue `.clang-format`, [padrões C++](instructions/cpp.instructions.md) e [padrões documentados](../docs/coding-standards.md). Não formatar a árvore inteira. Não executar formatadores em conteúdo protegido.
- Use regras determinísticas, testes de regressão, erros explícitos, ciclo de vida e segurança entre threads. Não invente evidência de compatibilidade, performance ou testes aprovados.
- Ao concluir, informe arquivos alterados, verificações realmente realizadas, limitações e validações manuais pendentes. Não declare build/testes executados quando houve apenas revisão estática.
- Commits, apenas quando solicitados ou após confirmação da feature pelo responsável: Conventional Commits em inglês; título ≤ 72 caracteres (limite do projeto, preferir ≤ 50) e corpo detalhado com linhas de até 72 caracteres. Não tratar esse valor como limite rígido universal do GitHub. Detalhes em [política de commits](instructions/commits.instructions.md).

## Referências

- [Plano completo e marcos](../docs/project-plan-2026-09-17.md)
- [Política de validação](../docs/validation-policy.md)
- [Auditoria dos recursos e contratos nativos](../docs/backend-resource-audit.md)
- [Origem e adaptação das regras](../docs/rules-migration.md)

Estas são instruções comportamentais, não um bloqueio técnico de escrita. Não alegue que garantem, por si só, imutabilidade criptográfica ou restrição de ferramentas.
