# Política de validação

## Responsabilidades

Testes automatizados fazem parte do projeto. Sua existência não autoriza agentes a executar builds ou código do projeto. As restrições abaixo valem também para subagentes, terminais, tarefas, wrappers e pipelines disparados pelo agente.

| Operação | Agente | Responsável / CI previamente configurada |
|---|---|---|
| Ler fontes e documentação não sensível | Permitido | Permitido |
| Escrever código, testes e configuração no escopo solicitado | Permitido, fora dos originais protegidos | Permitido, respeitando os originais |
| Inspecionar diff, whitespace, hashes e diagnósticos do editor | Permitido | Permitido |
| Verificação estática sem geração/build ou execução de código do projeto | Permitido | Permitido |
| Configurar, gerar, compilar, linkar, rebuild ou limpar build | Proibido | Responsabilidade externa ao agente |
| Instalar dependências via vcpkg com potencial compilação | Proibido | Responsabilidade externa ao agente |
| Executar CTest, testes compilados, cliente ou servidor | Proibido, mesmo com binários existentes | Ambiente controlado, conforme procedimento próprio |
| Disparar pipeline para contornar proibição | Proibido | Acionamento pelo responsável / automação já estabelecida |
| Formatar ou alterar frontend original | Proibido | Não faz parte deste projeto; contrato imutável |

Não executar CMake, presets, Ninja, MSBuild, Make ou equivalentes para configuração, geração ou build. Um pedido genérico de validação, a presença de artefatos ou a habilitação de edição não suspendem essas regras. Não executar scripts do projeto como alternativa a um comando proibido.

## Verificações estáticas e integridade

- Revisar apenas o diff pertinente, preservando mudanças anteriores do usuário.
- Conferir sintaxe e referências de instruções/documentação e diagnósticos disponíveis do editor.
- Usar inventário e SHA-256 para comparar arquivos antes/depois quando adequado, sem abrir dumps por conveniência. Hashes não constituem proteção de escrita e só demonstram o intervalo efetivamente comparado.
- Não executar formatadores nas árvores `data/`, `images/`, `qt/`, `qt-project.org/`, `qtwebchannel/`, `spells/` ou em `message.txt`.
- A `.clang-format` existente permanece intacta. Não normalizar o repositório inteiro, não copiar configuração global de editor que regrave originais.
- Não declarar compatibilidade QML, protocolo, ABI ou desempenho com base apenas em leitura.

## Testes planejados

A implementação futura deverá separar:

1. **Unitários:** regras determinísticas de domínio, aplicação de eventos, sessão e interpretação de dados com fixtures sintéticas locais. Sem dependência de servidor ou banco de trabalho.
2. **Integração Qt:** propriedades, sinais, roles, notificações dos modelos, ciclo de vida e recursos. GoogleTest para núcleo e Qt Test/Qt Quick Test são propostas a confirmar, não dependências instaladas.
3. **Integração com servidor:** exclusivamente 15.25, endpoints locais controlados, contas de teste e banco descartável. Não acionar rotinas destrutivas contra banco de desenvolvimento em uso.
4. **Ponta a ponta e visual:** frontend original inalterado, fluxos reais, DPI, coordenadas de entrada, desconexão e limpeza de estado.
5. **Desempenho:** cenários reproduzíveis, máquina/backend/versão registrados, correção funcional verificada separadamente.

CTest será o orquestrador proposto. CI Windows será planejada desde a fase 1, mas não existe como resultado desta tarefa. Sua criação/execução precisa respeitar licenças, isolamento de segredos e esta política. Agentes podem escrever configuração quando solicitados, mas não disparar pipelines.

## Encerramento de tarefas

Informar sempre:

- arquivos criados/alterados;
- verificações realmente feitas e seus resultados;
- bloqueios e incertezas;
- build, testes compilados e validação real pendentes para o responsável ou CI;
- ausência de execução, quando a revisão foi apenas estática.

Não inventar contagens de testes, métricas ou validações aprovadas. O aceite executável de cada marco do plano é uma obrigação futura do responsável/CI, não uma instrução de execução para agentes.
