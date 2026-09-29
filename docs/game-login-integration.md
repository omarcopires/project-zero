# Integração do login e entrada no mundo

## Fluxo conectado

`gamewindow.qml` agora recebe um controller Qt. O formulário original envia
as credenciais ao `AuthenticationService`, que usa o endpoint de
`network/login_service_url`. Uma resposta autenticada alimenta
`CharacterSelector` e abre o `CharacterSelection.qml` original com os nomes
de personagens e mundos recebidos. Credenciais recusadas, falhas de
transporte e desafios de verificação não suportados permanecem estados
distintos; o cliente não ignora 2FA nem registra senha ou chave de sessão.

Ao confirmar exatamente um personagem, o controller resolve o endpoint,
gera uma chave XTEA aleatória e inicia `WorldSessionService`. A tela só muda
para `INGAME` depois que a sessão é aceita e uma descrição inicial de mapa
é decodificada. Essa descrição é entregue ao `WorldMapItem` original; a
renderização continua limitada a sprites estáticos de um único campo.

## Configuração local

O cliente lê `client.ini` ao lado do executável. `CLIENT_CONFIG_FILE` pode
apontar para outro arquivo. O exemplo versionado está em
`client/config/local.example.ini`; copie-o como `client.ini` e configure:

- `network/login_service_url`: serviço HTTP de login do laboratório;
- `network/world_host` e `network/world_port`: ambos preenchidos para
  substituir o endereço recebido na resposta de login, ou ambos vazios para
  usar esse endereço;
- `network/asset_hash_identifier`: valor opcional do campo de identificação
  de assets no login do mundo. O servidor 15.25 deste laboratório lê e
  registra o campo sem validá-lo; o cliente envia uma string vazia quando
  nenhuma identificação foi configurada;
- `assets/directory`: diretório do catálogo e dos sprites. O padrão local é
  `things/assets`; `CLIENT_ASSETS_DIRECTORY` tem precedência.

O cliente não inventa um hash de assets. A entrada no mundo ainda depende
de confirmar que os assets locais correspondem aos IDs usados pelo servidor;
o inventário atual ainda registra essa validação
como pendente em `phase0-assets-verification.md`.

## Limites deste incremento

- Desafios 2FA são recusados com estado explícito; entrada de código e
  reenvio não estão conectados.
- O modelo de seleção expõe nome e mundo. Outfit, estado de premium,
  personagens ocultos, pins, loja, calendário e indicadores ao vivo não são
  fornecidos pela resposta de autenticação disponível.
- A sessão do mundo só mostra o mapa após receber e decodificar sua descrição
  inicial. Camadas, andares vizinhos, animações, iluminação, movimento,
  HUD, chat e comandos continuam fora desta integração.
- O lembrete de e-mail persiste somente o endereço quando ativado; a senha
  nunca é gravada.

Esta etapa foi revisada estaticamente. Compilação, os 158 testes e o fluxo
com servidor permanecem pendentes de validação externa para estas mudanças.
